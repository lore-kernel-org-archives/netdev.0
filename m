From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Shared i2c adapter locking (Was: linux-next: manual merge of
	the net tree with the i2c tree)
Date: Thu, 29 Oct 2009 15:09:36 +0000
Message-ID: <1256828976.2827.27.camel@achroite>
References: <20091026133757.7cf87e49.sfr@canb.auug.org.au>
	 <20091029154317.651904b9@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mika Kuoppala <mika.kuoppala@nokia.com>,
	Linux I2C <linux-i2c@vger.kernel.org>
To: Jean Delvare <khali@linux-fr.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091029154317.651904b9@hyperion.delvare>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-10-29 at 15:43 +0100, Jean Delvare wrote:
> Hi Stephen,
> 
> On Mon, 26 Oct 2009 13:37:57 +1100, Stephen Rothwell wrote:
> > Today's linux-next merge of the net tree got a conflict in
> > drivers/net/sfc/sfe4001.c between commit
> > 3f7c0648f727a6d5baf6117653e4001dc877b90b ("i2c: Prevent priority
> > inversion on top of bus lock") from the i2c tree and commit
> > c9597d4f89565b6562bd3026adbe6eac6c317f47 ("sfc: Merge sfe4001.c into
> > falcon_boards.c") from the net tree.
> > 
> > I have applied the following merge fixup patch (after removing
> > drivers/net/sfc/sfe4001.c) and can carry it as necessary.
> 
> Thanks for fixing it. The core problem here IMHO is that the sfc
> network driver touches i2c internals which it would rather leave alone.

I'm just a little proud of having the idea that we could avoid using an
I/O-expander on this board, but yes, the software side of this
multiplexing is a hack.

> This is the only driver I know of which does this.
> 
> I can think of 3 different ways to address the issue.
> 
> Method #1: add a public API to grab/release an I2C segment.
> 
> void i2c_adapter_lock(struct i2c_adapter *adapter)
> {
> 	rt_mutex_lock(&adapter->bus_lock);
> }
> 
> void i2c_adapter_unlock(struct i2c_adapter *adapter)
> {
> 	rt_mutex_unlock(&adapter->bus_lock);
> }
[...]
> I'm not really sure if I have a preference yet, so please speak up if
> you do.

Indirect lock operations are a recipe for deadlock, and there doesn't
seem to be any other user for this, so method 1 seems best.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
