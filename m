From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Wed, 11 Feb 2004 12:02:34 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211.120234.92333563.yoshfuji@linux-ipv6.org>
References: <20040210.125124.97248371.yoshfuji@linux-ipv6.org>
	<OFE4F39A6C.5E40D57D-ON88256E37.00008C47-88256E37.0003F08A@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, hibi665@oki.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OFE4F39A6C.5E40D57D-ON88256E37.00008C47-88256E37.0003F08A@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OFE4F39A6C.5E40D57D-ON88256E37.00008C47-88256E37.0003F08A@us.ibm.com> (at Tue, 10 Feb 2004 17:45:43 -0700), David Stevens <dlstevens@us.ibm.com> says:

> > likely(!(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI)))?
> 
>       If your question is "why use the deliver variable?", I left that
> because it'd
> need to be re-added when multicast routing is supported. This patch puts it
> back,
> and eliminates "discard" (including within the "#if 0" code).

No. 

My point is, !(skb->dev->flags & IFF_PROMISC|IFF_ALLMULTI) is likely true.

And, let's concentrate on fixing the original bug:

> @@ -238,23 +245,21 @@
> 
>                   if (deliver) {
>                         skb2 = skb_clone(skb, GFP_ATOMIC);
> +                       dst_output(skb2);
>                   } else {
> -                       discard = 0;
> -                       skb2 = skb;
> +                       dst_output(skb);
> +                       return 0;
>                   }
> -
> -                 dst_output(skb2);
>             }
>       }

and

>  #endif
> 
> -     if (deliver) {
> -           discard = 0;
> +     if (likely(deliver)) {
>             ip6_input(skb);
> +           return 0;
>       }
> -
> -     if (discard)
> -           kfree_skb(skb);
> +     /* discard */
> +     kfree_skb(skb);
> 

seems needless to fix the bug.

(Or you may want to submit another patch for them.)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
