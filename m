From: maximilian attems <janitor@sternwelten.at>
Subject: Re: [Kernel-janitors] ip_gre.c: update last_rx after netif_rx
Date: Sat, 21 Aug 2004 10:36:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040821083639.GA1827@stro.at>
References: <411E62D3.8070808@uranium235.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@lists.osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Bourque <kernel@uranium235.org>
Content-Disposition: inline
In-Reply-To: <411E62D3.8070808@uranium235.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 14 Aug 2004, Jay Bourque wrote:

> Fix to update last_rx after netif_rx
> This is my first patch so I'd appreciate any feedback.
> 
> -Jay
> 
> --- linux-2.6.8.1/net/ipv4/ip_gre.c    Sat Aug 14 05:55:48 2004
> +++ linux-2.6.8.1/net/ipv4/ip_gre.c.new    Sat Aug 14 12:17:16 2004
> @@ -646,6 +646,7 @@ int ipgre_rcv(struct sk_buff *skb)
>         nf_reset(skb);
>         ipgre_ecn_decapsulate(iph, skb);
>         netif_rx(skb);
> +       tunnel->dev->last_rx = jiffies;
>         read_unlock(&ipgre_lock);
>         return(0);
>     }
doesn't look complete, see patch below, but please read on:

the kj todo has an entry about "update last_rx after netif_rx", 
i wonder what that timestamping is good for, and newer 
sources 2.4.27 and 2.6.8 show 2 occurences of last_rx.

patches doing that are for young 2.4:
http://seclists.org/linux-kernel/2001/Feb/4846.html

i presume that this task is outdated,
thanks for putting light on that. 



--
maks
kernel janitor  	http://janitor.kernelnewbies.org/
