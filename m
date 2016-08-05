From: subashab@codeaurora.org
Subject: Re: [RFC PATCH] xfrm: Add option to reset oif in xfrm lookup
Date: Fri, 05 Aug 2016 15:57:30 -0600
Message-ID: <589520a9e6091d1b0c503303553510c7@codeaurora.org>
References: <1469493272-14894-1-git-send-email-subashab@codeaurora.org>
 <ceb825e1-cba5-e252-f8d1-30198797bbb2@cumulusnetworks.com>
 <7e8efab3f896b081adb6bbaf6613a569@codeaurora.org>
 <7c3836e2-adf0-8e04-8c2f-6ee714a38f70@cumulusnetworks.com>
 <3e4bb514a6fc5316c093f5f39cc07762@codeaurora.org>
 <3c59303e-f393-ab2f-733e-0769a615e685@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, netdev-owner@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57559 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S3003167AbcHEV5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2016 17:57:31 -0400
In-Reply-To: <3c59303e-f393-ab2f-733e-0769a615e685@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I need to do some additional testing next week (taking PTO the next 2
> days), but this should fix your problem. Can you confirm? This is
> better than a sysctl to handle the known use cases, but it does not
> handle a combination of the 2 known use cases (e.g., throw your use
> case into a VRF).
> 
> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
> index b644a23c3db0..41f5b504a782 100644
> --- a/net/ipv4/xfrm4_policy.c
> +++ b/net/ipv4/xfrm4_policy.c
> @@ -29,7 +29,7 @@ static struct dst_entry *__xfrm4_dst_lookup(struct
> net *net, struct flowi4 *fl4,
>         memset(fl4, 0, sizeof(*fl4));
>         fl4->daddr = daddr->a4;
>         fl4->flowi4_tos = tos;
> -       fl4->flowi4_oif = oif;
> +       fl4->flowi4_oif = l3mdev_master_ifindex_by_index(net, oif);
>         if (saddr)
>                 fl4->saddr = saddr->a4;

Thanks David. This works for me on 4.4 (along with commit 
1a8524794fc7c70f44ac28e3a6e8fd637bc41f14 ('net: l3mdev: Add master 
device lookup by index')).
Let me know if you have some other approach in mind or if this needs to 
be sent as an official patch.
