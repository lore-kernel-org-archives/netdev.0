From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: tg3 kernel oops when setting flow control while interface
 is down (2.6.10)
Date: Mon, 28 Feb 2005 09:26:25 -0800
Message-ID: <B1508D50A0692F42B217C22C02D84972020F3DCE@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: jluebbe@lasnet.de, davem@redhat.com
Content-class: urn:content-classes:message
To: "Daniel Willmann" <d.willmann@tu-bs.de>, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> 
> --- drivers/net/tg3.c.old	2005-02-27 23:26:48.000000000 +0100
> +++ drivers/net/tg3.c	2005-02-28 02:01:11.000000000 +0100
> @@ -6155,6 +6155,10 @@
>  {
>  	struct tg3 *tp = netdev_priv(dev);
>    
> +	if (!(tp->tg3_flags & TG3_FLAG_INIT_COMPLETE) ||
> +	    tp->link_config.phy_is_low_power)
> +		return -EAGAIN;
> +
>  	tg3_netif_stop(tp);
>  	spin_lock_irq(&tp->lock);
>  	spin_lock(&tp->tx_lock);
> 
> --------

I think it is better to just set the PAUSE flags and return 0 if
!netif_running(). This way, the settings will take effect when the device is
subsequently brought up.

Michael
