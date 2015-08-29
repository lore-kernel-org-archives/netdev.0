From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: vrf saddr selection
Date: Sat, 29 Aug 2015 16:43:27 -0700
Message-ID: <55E2439F.7040502@cumulusnetworks.com>
References: <20150829.164030.1189207364184023707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33855 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884AbbH2Xn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 19:43:29 -0400
Received: by pabzx8 with SMTP id zx8so99138240pab.1
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 16:43:28 -0700 (PDT)
In-Reply-To: <20150829.164030.1189207364184023707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/29/15 4:40 PM, David Miller wrote:
>
> In the output path we go:
>
> 	struct flowi4 fl4 = {
> 		/* needed to match OIF rule */
> 		.flowi4_oif = vrf_dev->ifindex,
> 		.flowi4_iif = LOOPBACK_IFINDEX,
> 		.flowi4_tos = RT_TOS(ip4h->tos),
> 		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_VRFSRC,
> 		.daddr = ip4h->daddr,
> 	};
>
> 	if (vrf_send_v4_prep(skb, &fl4, vrf_dev))
> 		goto err;
>
> 	if (!ip4h->saddr) {
> 		ip4h->saddr = inet_select_addr(skb_dst(skb)->dev, 0,
> 					       RT_SCOPE_LINK);
> 	}
>
> So in the case where the source address is needed, this
> inet_select_addr() call looks like useless work.
>
> The route lookup already filled in fl4.saddr for you, why don't we
> just use that?
>

We will. My intention is to remove the udp_sendmsg change and fill in 
the saddr in the VRF driver. In the process a fixed version of the above 
snippet is used.

David
