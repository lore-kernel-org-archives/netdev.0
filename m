From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-drivers-2.6 2/10] e1000: use netif_poll_{enable|disable}
Date: Tue, 15 Feb 2005 23:05:49 +0100
Message-ID: <20050215220549.GA1755@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.44.0502151110420.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>, netdev <netdev@oss.sgi.com>
To: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0502151110420.30336-100000@isotope.jf.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Malli Chilakala <mallikarjuna.chilakala@intel.com> :
[...]
> diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
> --- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2005-02-01 23:10:24.989105880 -0800
> +++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c	2005-02-01 23:10:26.709844288 -0800
> @@ -308,6 +308,9 @@ e1000_up(struct e1000_adapter *adapter)
>  	mod_timer(&adapter->watchdog_timer, jiffies);
>  	e1000_irq_enable(adapter);
>  
> +#ifdef CONFIG_E1000_NAPI
> +	netif_poll_enable(netdev);
> +#endif
>  	return 0;
>  }
>  

It leaves a small(*) window where the irq handler will do nothing with
the events it receives. If netif_poll_enable() is issued before
e1000_irq_enable(), the problem disappears.

[*] Assuming CONFIG_PREEMPT=n

--
Ueimor
