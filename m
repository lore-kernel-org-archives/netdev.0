From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] filter: add SKF_AD_NLATTR_NEST to look for nested
 attributes
Date: Mon, 17 Nov 2008 00:36:22 -0800 (PST)
Message-ID: <20081117.003622.132924683.davem@davemloft.net>
References: <20081117083136.10840.70283.stgit@Decadence>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	kaber@trash.net
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36705
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752141AbYKQIgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 03:36:23 -0500
In-Reply-To: <20081117083136.10840.70283.stgit@Decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 17 Nov 2008 09:31:37 +0100

> SKF_AD_NLATTR allows us to find the first matching attribute in a
> stream of netlink attributes from one offset to the end of the
> netlink message. This is not suitable to look for a specific
> matching inside a set of nested attributes.
> 
> For example, in ctnetlink messages, if we look for the CTA_V6_SRC
> attribute in a message that talks about an IPv4 connection,
> SKF_AD_NLATTR returns the offset of CTA_STATUS which has the same
> value of CTA_V6_SRC but outside the nest. To differenciate
> CTA_STATUS and CTA_V6_SRC, we would have to make assumptions on the
> size of the attribute and the usual offset, resulting in horrible
> BSF code.
> 
> This patch adds SKF_AD_NLATTR_NEST, which is a variant of
> SKF_AD_NLATTR, that looks for an attribute inside the limits of
> a nested attributes, but not further.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

This looks fine to me, Patrick is it ok with you too?

If Patrick has no objections I'll apply it to net-next-2.6
