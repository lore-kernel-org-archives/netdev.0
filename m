From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: [Bugme-new] [Bug 8057] New: slab corruption running ip6sic
Date: Thu, 22 Feb 2007 13:49:18 -0800
Message-ID: <20070222134918.e2f1af6d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, snakebyte@gmx.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40155 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751954AbXBVVtc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 16:49:32 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 22 Feb 2007 07:56:27 -0800
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 8057] New: slab corruption running ip6sic


http://bugzilla.kernel.org/show_bug.cgi?id=8057

           Summary: slab corruption running ip6sic
    Kernel Version: 2.6.21-rc1
            Status: NEW
          Severity: normal
             Owner: yoshfuji@linux-ipv6.org
         Submitter: snakebyte@gmx.de


Most recent kernel where this bug did *NOT* occur: unknown
Distribution: gentoo
Hardware Environment: AMD-K6, 400MHz, 288MB Ram
Software Environment: ip6sic (http://ip6sic.sourceforge.net/)
Problem Description:

When running ip6sic against the loopback interface i get the following kernel
messages:

[  199.514486] Slab corruption: start=d0505554, len=156
[  199.514704] Redzone: 0x5a2cf071/0x5a2cf071.
[  199.514859] Last user: [<c0465813>](kfree_skbmem+0x33/0x80)
[  199.515301] 080: 6b 6b 6b 6b 6b 6b 6b 6b 6a 6b 6b 6b 6b 6b 6b 6b
[  199.517096] Single bit error detected. Probably bad RAM.
[  199.517255] Run memtest86+ or a similar memory test tool.
[  199.517413] Prev obj: start=d05054ac, len=156
[  199.517568] Redzone: 0x170fc2a5/0x170fc2a5.
[  199.517719] Last user: [<c0465634>](skb_clone+0x34/0x1e0)
[  199.518088] 000: b4 52 50 d0 0c 52 50 d0 08 c6 4a d0 00 00 00 00
[  199.519851] 010: 00 00 00 00 00 00 00 00 5a 5a 5a 5a e0 a6 85 d0
[  199.521614] Next obj: start=d05055fc, len=156
[  199.521771] Redzone: 0x170fc2a5/0x170fc2a5.
[  199.521922] Last user: [<c0465634>](skb_clone+0x34/0x1e0)
[  199.522327] 000: 04 54
[  199.868486] Slab corruption: start=d0505554, len=156
[  199.869836] Redzone: 0x5a2cf071/0x5a2cf071.
[  199.870975] Last user: [<c0465813>](kfree_skbmem+0x33/0x80)
[  199.872820] 080: 6b 6b 6b 6b 6b 6b 6b 6b 6a 6b 6b 6b 6b 6b 6b 6b
[  199.879166] Single bit error detected. Probably bad RAM.
[  199.880347] Run memtest86+ or a similar memory test tool.
[  199.881539] Prev obj: start=d05054ac, len=156
[  199.882679] Redzone: 0x170fc2a5/0x170fc2a5.
[  199.883983] Last user: [<c0465634>](skb_clone+0x34/0x1e0)
[  199.885807] 000: b4 52 50 d0 0c 52 50 d0 08 c6 4a d0 00 00 00 00
[  199.892047] 010: 00 00 00 00 00 00 00 00 5a 5a 5a 5a e0 a6 85 d0
[  199.898369] Next obj: start=d05055fc, len=156
[  199.899511] Redzone: 0x170fc2a5/0x170fc2a5.
[  199.900642] Last user: [<c0465634>](skb_clone+0x34/0x1e0)
[  199.902471] 000: 04 54 50 d0 b4 52 50 d0 08 c6 4a d0 00 00 00 00
[  199.908818] 010: 00 00 00 00 00 00 00 00 5a 5a 5a 5a ec a8 85 d0
[  200.947125] Slab corruption: start=d0505554, len=156
[  200.948445] Redzone: 0x5a2cf071/0x5a2cf071.
[  200.949578] Last user: [<c0465813>](kfree_skbmem+0x33/0x80)
[  200.951417] 080: 6b 6b 6b 6b 6b 6b 6b 6b 6a 6b 6b 6b 6b 6b 6b 6b
[  200.957775] Single bit error detected. Probably bad RAM.
[  200.958960] Run memtest86+ or a similar memory test tool.
[  200.960155] Prev obj: start=d05054ac, len=156
[  200.961299] Redzone: 0x170fc2a5/0x170fc2a5.
[  200.962429] Last user: [<c0465634>](skb_clone+0x34/0x1e0)
[  200.964342] 000: b4 52 50 d0 0c 52 50 d0 08 c6 4a d0 00 00 00 00
[  200.970601] 010: 00 00 00 00 00 00 00 00 5a 5a 5a 5a e0 a6 85 d0
[  200.976934] Next obj: start=d05055fc, len=156
[  200.978074] Redzone: 0x170fc2a5/0x170fc2a5.
[  200.979200] Last user: [<c0465634>](skb_clone+0x34/0x1e0)
[  200.981021] 000: 04 54 50 d0 b4 52 50 d0 08 c6 4a d0 00 00 00 00
[  200.987374] 010: 00 00 00 00 00 00 00 00 5a 5a 5a 5a ec a8 85 d0

I compiled the kernel with network debugging, rebooted and startet ip6sic again:

[  141.573883] Slab corruption: start=d1a30b1c, len=156
[  141.575258] Redzone: 0x5a2cf071/0x5a2cf071.
[  141.576277] Last user: [<c0465813>](kfree_skbmem+0x33/0x80)
[  141.577909] 080: 6b 6b 6b 6b 6b 6b 6b 6b 6a 6b 6b 6b 6b 6b 6b 6b
[  141.583277] Single bit error detected. Probably bad RAM.
[  141.584321] Run memtest86+ or a similar memory test tool.
[  141.585442] Prev obj: start=d1a30a74, len=156
[  141.586452] Redzone: 0x170fc2a5/0x170fc2a5.
[  141.587453] Last user: [<c04660cc>](__alloc_skb+0x2c/0x120)
[  141.589059] 000: cc 09 a3 d1 fc fa a2 d1 00 00 00 00 00 00 00 00
[  141.594442] 010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  141.600358] Next obj: start=d1a30bc4, len=156
[  141.601416] Redzone: 0x170fc2a5/0x170fc2a5.
[  141.602420] Last user: [<c0465634>](skb_clone+0x34/0x1e0)
[  141.604032] 000: 6c 0c a3 d1 34 05 a3 d1 40 6e 48 d0 00 00 00 00
[  141.609495] 010: 00 00 00 00 00 00 00 00 5a 5a 5a 5a e4 7d 24 d1
[  141.861710] Slab corruption: start=d1a30b1c, len=156
[  141.862832] Redzone: 0x5a2cf071/0x5a2cf071.
[  141.863844] Last user: [<c0465813>](kfree_skbmem+0x33/0x80)
[  141.865522] 080: 6b 6b 6b 6b 6b 6b 6b 6b 6a 6b 6b 6b 6b 6b 6b 6b
[  141.870941] Single bit error detected. Probably bad RAM.
[  141.871993] Run memtest86+ or a similar memory test tool.
[  141.873052] Prev obj: start=d1a30a74, len=156
[  141.874068] Redzone: 0x170fc2a5/0x170fc2a5.
[  141.875143] Last user: [<c04660cc>](__alloc_skb+0x2c/0x120)
[  141.876758] 000: cc 09 a3 d1 fc fa a2 d1 00 00 00 00 00 00 00 00
[  141.882185] 010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  141.887653] Next obj: start=d1a30bc4, len=156
[  141.888668] Redzone: 0x170fc2a5/0x170fc2a5.
[  141.889671] Last user: [<c0465634>](skb_clone+0x34/0x1e0)
[  141.891274] 000: 6c 0c a3 d1 34 05 a3 d1 40 6e 48 d0 00 00 00 00
[  141.896735] 010: 00 00 00 00 00 00 00 00 5a 5a 5a 5a e4 7d 24 d1
[  142.160467] Slab corruption: start=d1a30b1c, len=156
[  142.161618] Redzone: 0x5a2cf071/0x5a2cf071.
[  142.162627] Last user: [<c0465813>](kfree_skbmem+0x33/0x80)
[  142.164243] 080: 6b 6b 6b 6b 6b 6b 6b 6b 6a 6b 6b 6b 6b 6b 6b 6b
[  142.169686] Single bit error detected. Probably bad RAM.
[  142.170729] Run memtest86+ or a similar memory test tool.
[  142.171784] Prev obj: start=d1a30a74, len=156
[  142.172796] Redzone: 0x170fc2a5/0x170fc2a5.
[  142.173798] Last user: [<c04660cc>](__alloc_skb+0x2c/0x120)
[  142.175463] 000: cc 09 a3 d1 fc fa a2 d1 00 00 00 00 00 00 00 00
[  142.180869] 010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  142.186327] Next obj: start=d1a30bc4, len=156
[  142.187343] Redzone: 0x170fc2a5/0x170fc2a5.
[  142.188349] Last user: [<c0465634>](skb_clone+0x34/0x1e0)
[  142.189952] 000: 6c 0c a3 d1 34 05 a3 d1 40 6e 48 d0 00 00 00 00
[  142.195522] 010: 00 00 00 00 00 00 00 00 5a 5a 5a 5a e4 7d 24 d1

I ran memtester (userspace memtest) which gave no errors, so i did a memtest86+,
the first 1 1/2 passes gave no errors, but I'll keep it running for a few more
hours.

Steps to reproduce:
ip6sic -i lo -d ::1 -p 1000

In case there are some config options or patches i should try, just say so. I'll
attach a .config in a few hours, but I guess I should let memtest86+ run for a
few more passes.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
