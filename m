From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [SECURITY] L2TP send buffer allocation size overflows
Date: Sun, 31 Oct 2010 14:14:44 -0400
Message-ID: <1288548884.3090.14.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:50805 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756228Ab0JaSOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 14:14:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both PPPoL2TP (in net/l2tp/l2tp_ppp.c, pppol2tp_sendmsg()) and IPoL2TP
(in net/l2tp/l2tp_ip.c, l2tp_ip_sendmsg()) make calls to sock_wmalloc()
that perform arithmetic on the size argument without any maximum bound.
As a result, by issuing sendto() calls with very large sizes, this
allocation size will wrap and result in a small buffer being allocated,
leading to ugliness immediately after (probably kernel panics due to bad
sk_buff tail position, but possibly kernel heap corruption).

This issue was just fixed in the core code with:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=253eacc070b114c2ec1f81b067d2fed7305467b0

Even though this won't be an issue for much longer, it should still be
fixed here just in case any paths to calling these functions with large
sizes are left open.

-Dan

