From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 3/7] vxlan: avoid checking socket multiple
 times.
Date: Wed, 9 Nov 2016 17:34:58 +0100
Message-ID: <20161109173458.1f57d699@griffin>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
        <1478371557-71888-4-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42176 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753480AbcKIQfB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 11:35:01 -0500
In-Reply-To: <1478371557-71888-4-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  5 Nov 2016 11:45:53 -0700, Pravin B Shelar wrote:
> @@ -2070,11 +2072,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  		struct dst_entry *ndst;
>  		u32 rt6i_flags;
>  
> -		if (!sock6)
> -			goto drop;
>  		sk = sock6->sock->sk;

I take back that the rest of the patch looks good. This will panic if
an IPv6 packet is routed (through encap route) to an IPv4-only
interface.

 Jiri
