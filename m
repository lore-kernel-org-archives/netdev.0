From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Fine-grained memory priorities and PI
Date: Thu, 15 Dec 2005 14:31:22 +0100
Message-ID: <20051215133122.GE23384@wotan.suse.de>
References: <20051215033937.GC11856@waste.org> <20051214.203023.129054759.davem@davemloft.net> <Pine.LNX.4.58.0512142318410.7197@w-sridhar.beaverton.ibm.com> <20051215.002120.133621586.davem@davemloft.net> <9E6D85FF-E546-4057-80EF-7479021AFAA1@mac.com> <20051215090401.GV23384@wotan.suse.de> <8FC3785F-01B3-4F9A-9E3C-89E90CB719B0@mac.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@davemloft.net>,
	sri@us.ibm.com, mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422724AbVLONbc@vger.kernel.org>
To: Kyle Moffett <mrmacman_g4@mac.com>
Content-Disposition: inline
In-Reply-To: <8FC3785F-01B3-4F9A-9E3C-89E90CB719B0@mac.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Naturally this is all still in the vaporware stage, but I think that  
> if implemented the concept might at least improve the OOM/low-memory  
> situation considerably.  Starting to fail allocations for the cluster  
> programs (including their kernel allocations) well before failing  
> them for the swap-fallback tool would help the original poster, and I  
> imagine various tweaked priorities would make true OOM-deadlock far  
> less likely.

The problem is that deadlocks can happen even without anybody
running out of virtual memory.  The deadlocks GFP_CRITICAL 
was supposed to handle are deadlocks while swapping out data
because the swapping on some devices needs more memory by itself.
This happens long before anything is running into a true oom. 
It's just that the memory cleaning stage cannot make progress
anymore.

Your proposal isn't addressing this problem at all I think.

Handling true OOM is a quite different issue.

-Andi
