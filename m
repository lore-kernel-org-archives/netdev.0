From: Manu Garg <manu.garg@med.ge.com>
Subject: Re: how ip header added in ip_bulid_xmit function?
Date: Tue, 18 May 2004 19:53:16 +0530
Sender: linux-net-owner@vger.kernel.org
Message-ID: <40AA1C54.2090201@med.ge.com>
References: <20040518063106.85290.qmail@web90102.mail.scd.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxnet <linux-net@vger.kernel.org>, netdev <netdev@oss.sgi.com>,
	netfilter <netfilter-devel@lists.netfilter.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: linux lover <linux_lover2004@yahoo.com>
In-Reply-To: <20040518063106.85290.qmail@web90102.mail.scd.yahoo.com>
List-Id: netdev.vger.kernel.org

linux lover wrote:

>hello ,
>   In ip_output.c file there is ip_build_xmit function
>call. when packet comes from tcp layer to IP layer
>this function is called. In that i found that 
>   skb = sock_alloc_send_skb(sk, length+hh_len+15
>,flags&MSG_DONTWAIT, &err);
>staement allocates skb for packet. after that i found
>that no iphdr adding statement in ip_build_xmit. i
>want to know where is iphdr push to skb? cause skb
>works using first alloc_skb to allocate memory then
>skb_reserve to reserve headroom then put data in skb
>by skb_put or skb_push for pushing headers in skb. so
>there i found       
>  skb->nh.iph = iph = (struct iphdr *)skb_put(skb,
>length); 
>statement is this does that iphdr adding?
>
>regards,
>linuxlover
>
>
>	
>		
>__________________________________
>Do you Yahoo!?
>SBC Yahoo! - Internet access at a great low price.
>http://promo.yahoo.com/sbc/
>-
>To unsubscribe from this list: send the line "unsubscribe linux-net" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>  
>
A packet comes from TCP layer to IP layer through function call 
tp->af_specific->queue_xmit() (in tcp_output.c:tcp_transmit_skb() ). For 
IP this function is nothing but ip_queue_xmit() defined in
ip_output.c.

If you'll check this function, it clearly allocates ip header and put 
information in it.

----------------------------------------------------
iph = (struct iphdr *) skb_push(skb, sizeof(struct iphdr) + (opt ? 
opt->optlen : 0));
        *((__u16 *)iph) = htons((4 << 12) | (5 << 8) | 
(sk->protinfo.af_inet.tos & 0xff));
iph->tot_len = htons(skb->len);
if (ip_dont_fragment(sk, &rt->u.dst))
    iph->frag_off = htons(IP_DF);
else
    iph->frag_off = 0;
iph->ttl      = sk->protinfo.af_inet.ttl;
iph->protocol = sk->protocol;
iph->saddr    = rt->rt_src;
iph->daddr    = rt->rt_dst;
skb->nh.iph   = iph;
---------------------------------------------------

I hope this answers your question.

regards,
Manu Garg
http://manugarg.freezope.org/notes




