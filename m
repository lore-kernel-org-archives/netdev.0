From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net] net/core: don't increment rx_dropped on
 inactive slaves
Date: Sun, 24 Jan 2016 22:42:22 -0800 (PST)
Message-ID: <20160124.224222.1748787418887617295.davem@davemloft.net>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453489882-57948-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Fri, 22 Jan 2016 14:11:22 -0500

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8cba3d8..1354c7b 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4153,8 +4153,11 @@ ncls:
>  		else
>  			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
>  	} else {
> +		if (deliver_exact)
> +			goto inactive; /* bond or team inactive slave */
>  drop:
>  		atomic_long_inc(&skb->dev->rx_dropped);
> +inactive:
>  		kfree_skb(skb);
>  		/* Jamal, now you will not able to escape explaining
>  		 * me how you were going to use this. :-)
> -- 
> 1.8.3.1
> 

I agree that rx_dropped is not the correct stat to bump here, but
I'm totally against the event disappearing completely into thin
air.

You have to replace the rx_dropped bump with _something_.

The only reason this hasn't been "fixed" yet is that everyone is
too damn lazy to implement that "something".
