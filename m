From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [janitor] remove casts in drivers/net/arm/
Date: Tue, 2 Mar 2004 12:10:42 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040302121042.A9931@flint.arm.linux.org.uk>
References: <20040229142516.3d218ed0.rddunlap@osdl.org> <20040229143436.4bb884ee.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040229143436.4bb884ee.rddunlap@osdl.org>; from rddunlap@osdl.org on Sun, Feb 29, 2004 at 02:34:36PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Feb 29, 2004 at 02:34:36PM -0800, Randy.Dunlap wrote:
>  drivers/net/arm/am79c961a.c |   18 +++++++++---------
>  drivers/net/arm/ether1.c    |   18 +++++++++---------
>  drivers/net/arm/ether3.c    |   18 +++++++++---------
>  drivers/net/arm/etherh.c    |    4 ++--
>  4 files changed, 29 insertions(+), 29 deletions(-)

I think we should really consider using netdev_priv() in all these places
so the compiler knows that 'dev' and 'priv' are related.

> diff -puN drivers/net/arm/am79c961a.c~net_arm_casts drivers/net/arm/am79c961a.c
> --- linux-263-229/drivers/net/arm/am79c961a.c~net_arm_casts	2004-02-29 13:53:00.000000000 -0800
> +++ linux-263-229-rddunlap/drivers/net/arm/am79c961a.c	2004-02-29 13:53:00.000000000 -0800
> @@ -196,7 +196,7 @@ am79c961_ramtest(struct net_device *dev,
>  static void
>  am79c961_init_for_open(struct net_device *dev)
>  {
> -	struct dev_priv *priv = (struct dev_priv *)dev->priv;
> +	struct dev_priv *priv = dev->priv;
>  	unsigned long flags;
>  	unsigned char *p;
>  	u_int hdr_addr, first_free_addr;

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
