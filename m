From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] drivers/net/tg3.c: Raise Jumbo Frame MTU to 9216?
Date: Wed, 15 Sep 2010 20:31:03 +0100
Message-ID: <1284579063.2293.28.camel@achroite.uk.solarflarecom.com>
References: <1284572516.10223.12.camel@Joe-Laptop>
	 <1284573454.8929.221.camel@HP1>  <1284578095.10223.27.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	Matthew Carlson <mcarlson@broadcom.com>,
	Benjamin Li <benli@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284578095.10223.27.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-15 at 12:14 -0700, Joe Perches wrote:
> On Wed, 2010-09-15 at 10:57 -0700, Michael Chan wrote:
> > On Wed, 2010-09-15 at 10:41 -0700, Joe Perches wrote:
> > > The TG3 apparently supports 9K frame sizes.
> > > http://www.broadcom.com/collateral/pb/5704C-PB05-R.pdf
> > > Is exactly 9000 a hardware limit?
> > > Should the jumbo frame MTU be raised to 9216 or 9216
> > > less the size of MAC, VLAN, IP and TCP headers?
> > 9000 has been the de facto standard, has it been changed recently?
> 
> I know of a performance lab that's trying to use 9216 as a "standard"
> jumbo frame length.
[...]

We also use 9000 as the 'normal' jumbo MTU, though hard limit in sfc is
a bit higher than this.

The frame length limit is not defined only by the DMA engine and FIFOs
but also by the MAC and PHY.  On the receive side, the MAC and/or PHY
need to handle skew between the remote and local clocks which can grow
proportionally with frame length.  For a controller which is used with
several different PHYs, I would be hesitant to raise the driver's limit.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
