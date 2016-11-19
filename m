From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netlink: smaller nla_attr_minlen table
Date: Sat, 19 Nov 2016 03:59:07 +0300
Message-ID: <20161119005907.GE1200@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35850 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbcKRW7Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 17:59:16 -0500
Received: by mail-wm0-f66.google.com with SMTP id m203so10761352wma.3
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 14:59:15 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Length of a netlink attribute may be u16 but lengths of basic attributes
are much smaller, so small we can save 16 bytes of .rodata and pocket
change inside .text.

16-bit is worse on x86-64 than 8-bit because of operand size override prefix.

	add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-19 (-19)
	function                                     old     new   delta
	validate_nla                                 418     417      -1
	nla_policy_len                                66      64      -2
	nla_attr_minlen                               32      16     -16
	Total: Before=154865051, After=154865032, chg -0.00%


Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 lib/nlattr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -14,7 +14,7 @@
 #include <linux/types.h>
 #include <net/netlink.h>
 
-static const u16 nla_attr_minlen[NLA_TYPE_MAX+1] = {
+static const u8 nla_attr_minlen[NLA_TYPE_MAX+1] = {
 	[NLA_U8]	= sizeof(u8),
 	[NLA_U16]	= sizeof(u16),
 	[NLA_U32]	= sizeof(u32),
