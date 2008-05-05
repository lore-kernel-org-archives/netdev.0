From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes
 infrequently
Date: Mon, 05 May 2008 16:18:06 -0700 (PDT)
Message-ID: <20080505.161806.267621711.davem@davemloft.net>
References: <bug-10600-10286@http.bugzilla.kernel.org/>
	<20080505155502.3fb16590.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com, liblit@acm.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41135
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763292AbYEEXSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 19:18:06 -0400
In-Reply-To: <20080505155502.3fb16590.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 5 May 2008 15:55:02 -0700

> I've noticed that when I'm downloading stuff at home, gkrellm will display
> eth0 as consuming 0 kbytes/sec, then 400 kbytes/sec, then 0, then 400 ad
> nauseum.  I always assumed that gkrellm was busted.  Perhaps wrongly...

It's a tradeoff between excess DMA traffic updating the statistics,
and having them updated more frequently.

Actually, the thing that matters is when ->get_stats() is called.

So if a driver can trigger a statistics DMA update at ->get_stats()
time, that's probably what it should do.  But this could get
expensive and make the "do DMA less often" optimization less useful.


