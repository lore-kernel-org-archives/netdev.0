From: Chris Ruehl <chris.ruehl@gtsys.com.hk>
Subject: Re: ipv6: oops in datagram.c line 260
Date: Wed, 28 Jan 2015 11:50:41 +0800
Message-ID: <54C85C91.4010700@gtsys.com.hk>
References: <5487DD65.60800@gtsys.com.hk> <549AC2B4.8070203@gtsys.com.hk> <1420560073.32369.60.camel@redhat.com> <20150126083512.GI13046@secunet.com> <54C71AFB.40300@gtsys.com.hk> <20150127115814.GL13046@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fpasia.hk ([202.130.89.98]:57342 "EHLO fpa01n0.fpasia.hk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753053AbbA1Dur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 22:50:47 -0500
In-Reply-To: <20150127115814.GL13046@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, January 27, 2015 07:58 PM, Steffen Klassert wrote:
> On Tue, Jan 27, 2015 at 12:58:35PM +0800, Chris Ruehl wrote:
>>
>>     Steffen,
>>
>>     your patch can't apply to the vanilla v3.14.29 can you cross check please.
>
> Sorry, this patch was based on the net tree.
>
>>     I'm sorry but we running a productive system and I can't make to much
>>     noise here!
>>     Your patch is partly in the 3.14.29 and
>>     skb->protocol = htons(ETH_P_IP)
>>     from the xfrm4/6_output_finish() no removed. I do then
>>
>>     --- linux-3.14.x/net/ipv4/xfrm4_output.c.orig    2015-01-27
>>     12:50:01.830651344 +0800
>>     +++ linux-3.14.x/net/ipv4/xfrm4_output.c    2015-01-27 12:51:13.280386355
>>     +0800
>>     @@ -82,7 +82,6 @@
>>          IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
>>      #endif
>>
>>     -    skb->protocol = htons(ETH_P_IP);
>>          return xfrm_output(skb);
>>      }
>>
>>     --- linux-3.14.x/net/ipv6/xfrm6_output.c.orig    2015-01-27
>>     12:49:39.260735321 +0800
>>     +++ linux-3.14.x/net/ipv6/xfrm6_output.c    2015-01-27 12:50:47.280482636
>>     +0800
>>     @@ -132,7 +132,6 @@
>>          IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
>>      #endif
>>
>>     -    skb->protocol = htons(ETH_P_IPV6);
>>          return xfrm_output(skb);
>>      }
>
> Yes, that should be ok. Here is the complete patch for v3.14.29:
>
> Subject: [PATCH RFC v3.14.29] xfrm: Fix local error reporting crash with interfamily tunnels
>
> We set the outer mode protocol too early. As a result, the
> local error handler might dispatch to the wrong address family
> and report the error to a wrong socket type. We fix this by
> seting the outer protocol to the skb only after we accessed the
> inner mode for the last time, right before we do the atcual
> encapsulation where we switch finally to the outer mode.
> The settings in xfrm{4,6}_output_finish() are removed.
>
> Reported-by: Chris Ruehl <chris.ruehl@gtsys.com.hk>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>   net/ipv4/xfrm4_output.c |    1 -
>   net/ipv6/xfrm6_output.c |    1 -
>   2 files changed, 0 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
> index baa0f63..0cb9606 100644
> --- a/net/ipv4/xfrm4_output.c
> +++ b/net/ipv4/xfrm4_output.c
> @@ -82,7 +82,6 @@ int xfrm4_output_finish(struct sk_buff *skb)
>   	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
>   #endif
>
> -	skb->protocol = htons(ETH_P_IP);
>   	return xfrm_output(skb);
>   }
>
> diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
> index 6cd625e..98396cf 100644
> --- a/net/ipv6/xfrm6_output.c
> +++ b/net/ipv6/xfrm6_output.c
> @@ -132,7 +132,6 @@ int xfrm6_output_finish(struct sk_buff *skb)
>   	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
>   #endif
>
> -	skb->protocol = htons(ETH_P_IPV6);
>   	return xfrm_output(skb);
>   }
>
>
Applied, wait for a window for reboot the system. And wait :0)

Chris
