From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch] tehuti: using uninitialized data in bdx_ioctl_priv()
Date: Mon, 24 Jun 2013 21:24:12 +0100
Message-ID: <1372105452.1896.45.camel@bwh-desktop.uk.level5networks.com>
References: <20130624160503.GC31984@elgon.mountain>
	 <20130624.130145.1513695698751905735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <dan.carpenter@oracle.com>, <andy@greyhouse.net>,
	<netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130624.130145.1513695698751905735.davem@davemloft.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-06-24 at 13:01 -0700, David Miller wrote:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Mon, 24 Jun 2013 19:05:03 +0300
> 
> > If we "cmd == SIOCDEVPRIVATE" then we use data[] without initializing
> > it.  The most common case is that we would return -EOPNOTSUPP.  The
> > other case is that we'd end up reading and writing to randomish places.
> > This requires CAP_SYS_RAWIO so it's not very bad.
> > 
> > The fix is to not allow SIOCDEVPRIVATE because it doesn't work.  I
> > returned -EOPNOTSUPP instead of -ENOTTY because that's what is used in
> > the rest of the file.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> I think the intention is to only allow SIOCDEVPRIVATE, rather than
> accept any and all values other than it which are inside of the
> private ioctl range.
> 
> The 'cmd' validation is one step, and it determines the interpretation
> of data[0].

But data is only initialised on the error path.  So this whole function
is useless.  It might as well be removed entirely.

(Also, drivers generally should not assign SIOCDEVPRIVATE+{0,1,2}, as
those numbers used to be conventionally used for MII operations.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

