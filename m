From: Roland Dreier <rdreier@cisco.com>
Subject: Re: intermittant petabyte usage reported with broadcom nic
Date: Thu, 12 Apr 2007 16:28:37 -0700
Message-ID: <adak5whdvfe.fsf@cisco.com>
References: <20070402014319.GA8345@zip.com.au>
	<20070402001300.3b66007d.akpm@linux-foundation.org>
	<20070412225249.GU8345@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: CaT <cat@zip.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:39387 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906AbXDLX2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 19:28:42 -0400
In-Reply-To: <20070412225249.GU8345@zip.com.au> (cat@zip.com.au's message of "Fri, 13 Apr 2007 08:52:49 +1000")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Adding Michael Chan, who seems to look after bnx2, to the cc list]

 > To clarify it's an Intel Dual Core Xeon (I just wound up as thinking of
 > them all as amd64s). Network card driver in use is the one defined by
 > CONFIG_BNX2. Kernel's monolithic.

>From a quick look at bnx2.c, it seems that the driver gives the NIC
(firmware?) a block of memory to DMA stats into, and just reads from
that memory in its get_stats method.  So if you're seeing wonky stats
from the NIC intermittently, my best guess would be that firmware is
occasionally writing junk into the stats block.

 - R.
