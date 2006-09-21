From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 7179] New: Compilation of .tmp_linux1 fails
 due to missing declaration in net/netfilter/xt_physdev.c
Date: Thu, 21 Sep 2006 15:37:01 -0700
Message-ID: <20060921153701.2c49e331.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:22250 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932078AbWIUWhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 18:37:12 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k8LMb1nW025057
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 15:37:02 -0700
Received: from akpm.corp.google.com (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id k8LMb16D007766
	for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 15:37:01 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Methinks CONFIG_NETFILTER_XT_TARGET_CLASSIFY should depend upon
CONFIG_BRIDGE_NETFILTER.  Because brnf_deferred_hooks is defined in
net/bridge/br_netfilter.c and is referred to in net/netfilter/xt_physdev.c.

Or something else ;)



Begin forwarded message:

Date: Thu, 21 Sep 2006 14:41:13 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7179] New: Compilation of .tmp_linux1 fails due to missing declaration in net/netfilter/xt_physdev.c


http://bugzilla.kernel.org/show_bug.cgi?id=7179

           Summary: Compilation of .tmp_linux1 fails due to missing
                    declaration in net/netfilter/xt_physdev.c
    Kernel Version: 2.6.18
            Status: NEW
          Severity: high
             Owner: laforge@gnumonks.org
         Submitter: gfrank@neoservers.com


Most recent kernel where this bug did not occur: 2.6.17.13
Distribution: CentOS
Hardware Environment: Dual Intel Xeon 5160
Software Environment: gcc 3.4.6, glibc 2.3.4, make 3.8
Problem Description:

Using the same config from 2.6.17.13, kernel 2.6.18 fails on make when 
attempting to make .tmp_vmlinux1

LD      .tmp_vmlinux1
net/built-in.o(.text.checkentry+0x1e1): In function `checkentry':
net/netfilter/xt_physdev.c:130: undefined reference to `brnf_deferred_hooks'
make: *** [.tmp_vmlinux1] Error 1

Line 130 is simply "brnf_deferred_hooks = 1;"  This variable is also used on 
line 118.

Adding 

"int brnf_deferred_hooks = 0;" 

in a line before line 104 (static int) will cause .tmp_vmlinux1 to be 
successfully created, and make will finish successfully.  However, it will 
generate a warning (seen below) on now line 119 which can be fixed by changing 
it to: 

"if ((brnf_deferred_hooks == 0) & (info->bitmask & XT_PHYSDEV_OP_OUT) && "

The warning generated is:

net/netfilter/xt_physdev.c: In function `checkentry':
net/netfilter/xt_physdev.c:118: warning: ISO C90 forbids mixed declarations 
and code

The kernel produced after making these changes works fine

Steps to reproduce:

I am unsure of which kernel .config parameter is sparking this.  My .config 
can be found here: http://www.animeforum.com/jakiao/misato.config

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
