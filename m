From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/6] xen-netfront: reduce gso_max_size to account for
 ethernet header
Date: Mon, 25 Mar 2013 10:24:31 -0700
Message-ID: <1364232271.29473.27.camel@edumazet-glaptop>
References: <1364209702-12437-3-git-send-email-wei.liu2@citrix.com>
	 <20130325.121809.2023305728304341952.davem@davemloft.net>
	 <1364230472.29473.21.camel@edumazet-glaptop>
	 <20130325.125949.1046297562456662826.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, ian.campbell@citrix.com,
	annie.li@oracle.com, konrad.wilk@oracle.com,
	david.vrabel@citrix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f170.google.com ([209.85.210.170]:33059 "EHLO
	mail-ia0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758012Ab3CYRYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 13:24:34 -0400
Received: by mail-ia0-f170.google.com with SMTP id h8so5730398iaa.1
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 10:24:34 -0700 (PDT)
In-Reply-To: <20130325.125949.1046297562456662826.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-25 at 12:59 -0400, David Miller wrote:

> If this GRO packet ends up being transmitted, the gso limit should be
> applied, otherwise we would be violating the device's advertised GSO
> limit value.
> 
> Assume that this kind of check is performed (it must), then I don't
> see how GRO can cause any problems for Xen.

It seems nobody cared to perform this generic check.

netif_skb_features() only deals with max_segs :

if (skb_shinfo(skb)->gso_segs > skb->dev->gso_max_segs) 
	features &= ~NETIF_F_GSO_MASK; 


dev->gso_max_size is currently only used to populate sk->sk_gso_max_size

For regular 1500 MTU and at most 17 frags per skb, its hardly a problem,
but it could happen with jumbo frames, or using loopback and splice()
