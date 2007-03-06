From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [patch 2/2] div64_64: common code
Date: Tue, 6 Mar 2007 19:46:32 +0000
Message-ID: <20070306194632.GA28949@linux-mips.org>
References: <200703061042.l26AgS0U019809@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, chris@zankel.net,
	geert@linux-m68k.org, jdike@addtoit.com, rmk@arm.linux.org.uk,
	zippel@linux-m68k.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:34007 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933299AbXCFTsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 14:48:43 -0500
Received: from localhost.localdomain ([127.0.0.1]:18344 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021445AbXCFTsk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 19:48:40 +0000
Content-Disposition: inline
In-Reply-To: <200703061042.l26AgS0U019809@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 02:42:28AM -0800, akpm@linux-foundation.org wrote:

> Implement div64_64(): 64-bit by 64-bit division.  Needed by networking (at
> least).

Your patch only implements div64_64() for 32-bit MIPS.  Below patch adds
the trivial 64-bit bits.

  Ralf

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 include/asm-mips/div64.h |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

Index: linux-mips/include/asm-mips/div64.h
===================================================================
--- linux-mips.orig/include/asm-mips/div64.h
+++ linux-mips/include/asm-mips/div64.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2000, 2004  Maciej W. Rozycki
- * Copyright (C) 2003 Ralf Baechle
+ * Copyright (C) 2003, 07 Ralf Baechle (ralf@linux-mips.org)
  *
  * This file is subject to the terms and conditions of the GNU General Public
  * License.  See the file "COPYING" in the main directory of this archive
@@ -105,6 +105,11 @@ extern uint64_t div64_64(uint64_t divide
 	(n) = __quot; \
 	__mod; })
 
+static inline uint64_t div64_64(uint64_t dividend, uint64_t divisor)
+{
+	return dividend / divisor;
+}
+
 #endif /* (_MIPS_SZLONG == 64) */
 
 #endif /* _ASM_DIV64_H */
