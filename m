From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: some bluetooth fixes
Date: Sat, 07 Feb 2004 00:30:08 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076110207.14418.53.camel@pegasus>
References: <20040206050042.20a2b3b0.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bluez-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        viro@zenII.linux.org.uk
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040206050042.20a2b3b0.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Andi,

> diff -u linux-2.6.2-work32/net/bluetooth/rfcomm/tty.c-o linux-2.6.2-work32/net/bluetooth/rfcomm/tty.c
> --- linux-2.6.2-work32/net/bluetooth/rfcomm/tty.c-o	2003-09-28 10:53:25.000000000 +0200
> +++ linux-2.6.2-work32/net/bluetooth/rfcomm/tty.c	2004-02-06 04:58:28.000000000 +0100
> @@ -549,8 +549,10 @@
>  
>  	BT_DBG("dev %p dst %s channel %d opened %d", dev, batostr(&dev->dst), dev->channel, dev->opened);
>  
> -	if (dev->opened++ != 0)
> +	if (dev->opened++ != 0) {
> +		rfcomm_dev_put(dev);
>  		return 0;
> +	}
>  
>  	dlc = dev->dlc;

this part is wrong, because it is not an error case. It is success and
the refcount must stay increased.

Regards

Marcel
