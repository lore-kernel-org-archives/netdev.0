From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v2] IPv6: fix bug when specifying the non-exist outgoing
 interface
Date: Mon, 02 Jun 2008 12:26:48 -0400
Message-ID: <48441F48.2080607@hp.com>
References: <4843AB51.6010206@cn.fujitsu.com> <20080602.172009.84304151.yoshfuji@linux-ipv6.org> <4843B65C.1060702@cn.fujitsu.com> <48441C82.1070609@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000308070901070406080708"
Cc: =?windows-1252?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:31162 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542AbYFBQ0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 12:26:51 -0400
In-Reply-To: <48441C82.1070609@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000308070901070406080708
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

> I did notice a slight problem where if fl->oif is set in the caller (for 
> example via SO_BINDTODEVICE), it's ignored in datagram_send_ctl() if 
> src_info->ipi6_ifindex is zero, attached patch fixes that.

Actually, previous patch wasn't exactly correct either, I missed one 
conversion, below is ok.

-Brian

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

--------------000308070901070406080708
Content-Type: text/x-diff;
 name="datagram_send_ctl.floif.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="datagram_send_ctl.floif.patch"

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 94fa6ae..3abe181 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -541,10 +541,10 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 				break;
 
 			if (addr_type & IPV6_ADDR_LINKLOCAL) {
-				if (!src_info->ipi6_ifindex)
+				if (!fl->oif)
 					return -EINVAL;
 				else {
-					dev = dev_get_by_index(&init_net, src_info->ipi6_ifindex);
+					dev = dev_get_by_index(&init_net, fl->oif);
 					if (!dev)
 						return -ENODEV;
 				}

--------------000308070901070406080708--
