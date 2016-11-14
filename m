From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] icmp: Restore resistence to abnormal messages
Date: Mon, 14 Nov 2016 13:36:46 -0500 (EST)
Message-ID: <20161114.133646.1687576478968660327.davem@davemloft.net>
References: <20161111202018.13795-1-googuy@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: googuy@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161111202018.13795-1-googuy@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vicente Jimenez Aguilar <googuy@gmail.com>
Date: Fri, 11 Nov 2016 21:20:18 +0100

> @@ -819,6 +820,12 @@ static bool icmp_unreach(struct sk_buff *skb)
>  				/* fall through */
>  			case 0:
>  				info = ntohs(icmph->un.frag.mtu);
> +				/* Handle weird case where next hop MTU is
> +				 * equal to or exceeding dropped packet size
> +				 */
> +				old_mtu = ntohs(iph->tot_len);
> +				if (info >= old_mtu)
> +					info = old_mtu - 2;

This isn't something the old code did.

The old code behaved much differently.

In the case where the new mtu was smaller than 68 or larger than
the iph->tot_len value, it would do several things:

1) First it would check for a BSD 4.2 anomaly and subtract old_mtu
   by the IP header length.

2) Second, it would try to guess the intended MTU using the
   mtu_plateau table.

I don't see any code where a subtraction by a fixed constant of 2
occurred.

Nor can I figure out what that might accomplish.  If you really
want to do this, you have to docuement what this 2 means, what
it is accomplishing, and why you have choosen to accomplish it
this way.

Thanks.
