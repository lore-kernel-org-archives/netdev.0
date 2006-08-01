From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/23] [PATCH] [XFRM]: Add XFRM_MODE_xxx for future use.
Date: Tue, 01 Aug 2006 16:52:32 -0700 (PDT)
Message-ID: <20060801.165232.95060501.davem@davemloft.net>
References: <11541653852481-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57245
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750752AbWHAXw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 19:52:29 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <11541653852481-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Sat, 29 Jul 2006 18:29:45 +0900

> Transformation mode is used as either IPsec transport or tunnel.
> It is required to add two more items, route-optimization and inbound trigger
> by Mobile IPv6.
> Based on MIPL2 kernel patch.

This change looks fine, but please explain the inconsistent
transformation done in xfrm4_encap() vs. xfrm6_encap().

In xfrm4_encap() the test is modified like this:

> -	if (!x->props.mode) {
> +	if (x->props.mode == XFRM_MODE_TRANSPORT) {

specifically allowing only XFRM_MODE_TRANSPORT, whereas in
xfrm6_encap() we do this:

> -	if (!x->props.mode) {
> +	if (x->props.mode != XFRM_MODE_TUNNEL) {

which changes the test to match all non-tunnels.

Unless there is a reason to do things differently, we should make the
checks identical even if ipv4 will never use values other than
XFRM_MODE_TUNNEL and XFRM_MODE_TRANSPORT.
