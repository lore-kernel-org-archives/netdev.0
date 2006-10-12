From: Dave Jones <davej@redhat.com>
Subject: sfuzz hanging on 2.6.18
Date: Thu, 12 Oct 2006 03:37:20 -0400
Message-ID: <20061012073720.GB9274@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44485 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1422786AbWJLHhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 03:37:21 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k9C7bLkJ012135
	for <netdev@vger.kernel.org>; Thu, 12 Oct 2006 03:37:21 -0400
Received: from pressure.kernelslacker.org (vpn-248-1.boston.redhat.com [10.13.248.1])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k9C7bL6Y015946
	for <netdev@vger.kernel.org>; Thu, 12 Oct 2006 03:37:21 -0400
Received: from pressure.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by pressure.kernelslacker.org (8.13.8/8.13.8) with ESMTP id k9C7bKdx010517
	for <netdev@vger.kernel.org>; Thu, 12 Oct 2006 03:37:20 -0400
Received: (from davej@localhost)
	by pressure.kernelslacker.org (8.13.8/8.13.8/Submit) id k9C7bKeG010516
	for netdev@vger.kernel.org; Thu, 12 Oct 2006 03:37:20 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sfuzz.c (google for it if you don't have it already) used to
run forver (or until I got bored and ctrl-c'd it) as long
as it didn't trigger an oops or the like in 2.6.17

Running it against 2.6.18, I notice that it runs for a while,
and then gets totally wedged.  It doesn't respond to any signals,
can't be ptraced, and even strace subsequently gets wedged.
The machine responds, and is still interactive, but that process
is hosed.

sysrq-t shows it stuck here..

sfuzz         D 724EF62A  2828 28717  28691                     (NOTLB)
       cd69fe98 00000082 0000012d 724ef62a 0001971a 00000010 00000007 df6d22b0 
       dfd81080 725bbc5e 0001971a 000cc634 00000001 df6d23bc c140e260 00000202 
       de1d5ba0 cd69fea0 de1d5ba0 00000000 00000000 de1d5b60 de1d5b8c de1d5ba0 
Call Trace:
 [<c05b1708>] lock_sock+0x75/0xa6
 [<e0b0b604>] dn_getname+0x18/0x5f [decnet]
 [<c05b083b>] sys_getsockname+0x5c/0xb0
 [<c05b0b46>] sys_socketcall+0xef/0x261
 [<c0403f97>] syscall_call+0x7/0xb
DWARF2 unwinder stuck at syscall_call+0x7/0xb

I wonder if the plethora of lockdep related changes inadvertantly broke something?

	Dave

-- 
http://www.codemonkey.org.uk
