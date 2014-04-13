From: David Miller <davem@davemloft.net>
Subject: audit regression on x86 32-bit
Date: Sun, 13 Apr 2014 15:00:02 -0400 (EDT)
Message-ID: <20140413.150002.2000370566602899725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, ast@plumgrid.com, torvalds@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755470AbaDMTAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2014 15:00:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Linus reported to me that Chrome stopped working on x86 32-bit for
him, and he gets a bunch of audit errors in his log:

  audit: type=1326 audit(1397359304.356:28108): auid=500 uid=500
gid=500 ses=2 subj=unconfined_u:unconfined_r:chrome_sandbox_t:s0-s0:c0.c1023
pid=3677 comm="chrome" exe="/opt/google/chrome/chrome" sig=0
syscall=172 compat=0 ip=0xb2dd9852 code=0x30000

  audit: type=1326 audit(1397359304.356:28109): auid=500 uid=500
gid=500 ses=2 subj=unconfined_u:unconfined_r:chrome_sandbox_t:s0-s0:c0.c1023
pid=3677 comm="chrome" exe="/opt/google/chrome/chrome" sig=0 syscall=5
compat=0 ip=0xb2dd9852 code=0x50000

He hasn't finished bisecting but it is starting to look like it's
the BPF changes that went into this merge window.

Daniel and Alexei can you guys look into this?

Thanks.
