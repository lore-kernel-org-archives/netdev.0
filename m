From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] net: can: af_can.c: Fix checkpatch warnings
Date: Sun, 10 Mar 2013 13:45:22 +0100
Message-ID: <513C8062.6030001@hartkopp.net>
References: <1362918526-26730-1-git-send-email-valentin.ilie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Valentin Ilie <valentin.ilie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362918526-26730-1-git-send-email-valentin.ilie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hallo Valentin,

thanks for the idea for the cleanup.

But if you replace the the printk() statements it's worth to check if code
fits into a single line now, e.g.

On 10.03.2013 13:28, Valentin Ilie wrote:

 		r = NULL;
> @@ -749,7 +749,7 @@ int can_proto_register(const struct can_proto *cp)
>  	int err = 0;
>  
>  	if (proto < 0 || proto >= CAN_NPROTO) {
> -		printk(KERN_ERR "can: protocol number %d out of range\n",
> +		pr_err("can: protocol number %d out of range\n",
>  		       proto);


here " ,proto);" can obviously be move into the previous line while preserving
the 80 chars per line rule.


>  		return -EINVAL;
>  	}
> @@ -761,7 +761,7 @@ int can_proto_register(const struct can_proto *cp)
>  	mutex_lock(&proto_tab_lock);
>  
>  	if (proto_tab[proto]) {
> -		printk(KERN_ERR "can: protocol %d already registered\n",
> +		pr_err("can: protocol %d already registered\n",
>  		       proto);


here too

>  		err = -EBUSY;
>  	} else
> @@ -817,8 +817,7 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
>  		/* create new dev_rcv_lists for this device */
>  		d = kzalloc(sizeof(*d), GFP_KERNEL);
>  		if (!d) {
> -			printk(KERN_ERR
> -			       "can: allocation of receive list failed\n");
> +			pr_err("can: allocation of receive list failed\n");
>  			return NOTIFY_DONE;
>  		}


As i've seen in former patches from Joe Perches OOM messages are obsolete.

You could write

if(!d)
	return NOTIFY_DONE;

here instead.

Thanks,
Oliver
