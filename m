From: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: tty_register_device NULL pointer dereference in 2.6.31-rc4
Date: Sat, 01 Aug 2009 11:21:28 +0200
Message-ID: <4A740918.1040504@hartkopp.net>
References: <20090727095904.GA5442@darkstar> <4A6D8BA3.3030601@hartkopp.net> <4A6D91D7.6030204@hartkopp.net> <20090727140736.GA1864@darkstar> <4A705604.3040807@hartkopp.net> <a8e1da0907300215q3934da47g3676648e3b247af8@mail.gmail.com> <4A717083.5090101@hartkopp.net> <20090731093949.GA4867@darkstar> <a8e1da0907310310h483cedeeg433947d51345246c@mail.gmail.com> <4A72D373.7080802@hartkopp.net> <20090801031705.GA2817@darkstar>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090801031705.GA2817@darkstar>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> --- linux-2.6.orig/include/net/bluetooth/rfcomm.h	2009-08-01 10:53:18.000000000 +0800
> +++ linux-2.6/include/net/bluetooth/rfcomm.h	2009-08-01 10:55:29.000000000 +0800
> @@ -355,7 +355,18 @@ struct rfcomm_dev_list_req {
>  };
>  
>  int  rfcomm_dev_ioctl(struct sock *sk, unsigned int cmd, void __user *arg);
> +
> +#ifdef CONFIG_BT_RFCOMM_TTY
>  int  rfcomm_init_ttys(void);
>  void rfcomm_cleanup_ttys(void);
> -
> +#else
> +static inline int rfcomm_init_ttys(void)
> +{
> +	return 0;
> +}
> +static inline int rfcomm_cleanup_ttys(void)
> +{
> +	return 0;
> +}
> +#endif

Just a minor thing:

Does rfcomm_cleanup_ttys() return 'int' or is it 'void' ?

Regards,
Oliver
