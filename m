From: Andi Kleen <andi@firstfloor.org>
Subject: Re: intermittant petabyte usage reported with broadcom nic
Date: 13 Apr 2007 03:15:59 +0200
Message-ID: <p73hcrl6pm8.fsf@bingen.suse.de>
References: <20070402014319.GA8345@zip.com.au>
	<20070402001300.3b66007d.akpm@linux-foundation.org>
	<20070412225249.GU8345@zip.com.au> <adak5whdvfe.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: CaT <cat@zip.com.au>, Michael Chan <mchan@broadcom.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59553 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753932AbXDMARs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 20:17:48 -0400
In-Reply-To: <adak5whdvfe.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier <rdreier@cisco.com> writes:

> [Adding Michael Chan, who seems to look after bnx2, to the cc list]
> 
>  > To clarify it's an Intel Dual Core Xeon (I just wound up as thinking of
>  > them all as amd64s). Network card driver in use is the one defined by
>  > CONFIG_BNX2. Kernel's monolithic.
> 
> From a quick look at bnx2.c, it seems that the driver gives the NIC
> (firmware?) a block of memory to DMA stats into, and just reads from
> that memory in its get_stats method.  So if you're seeing wonky stats
> from the NIC intermittently, my best guess would be that firmware is
> occasionally writing junk into the stats block.

When only the firmware is writing to that area it could be put
into an own page and then write protected with change_page_attr()
That would catch any corruption coming from the rest of the kernel.

-Andi
