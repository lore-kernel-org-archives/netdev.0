From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/3] r8169: Use load_acquire() and store_release() to
 reduce memory barrier overhead
Date: Sat, 15 Nov 2014 22:13:50 +0100
Message-ID: <20141115211350.GA24817@electric-eye.fr.zoreil.com>
References: <20141113191250.12579.19694.stgit@ahduyck-server>
 <20141113192735.12579.22892.stgit@ahduyck-server>
 <20141113213049.GA12297@electric-eye.fr.zoreil.com>
 <54653ABF.3080400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mikey@neuling.org,
	tony.luck@intel.com, mathieu.desnoyers@polymtl.ca,
	donald.c.skidmore@intel.com, peterz@infradead.org,
	benh@kernel.crashing.org, heiko.carstens@de.ibm.com,
	oleg@redhat.com, will.deacon@arm.com, davem@davemloft.net,
	michael@ellerman.id.au, matthew.vick@intel.com,
	nic_swsd@realtek.com, geert@linux-m68k.org,
	jeffrey.t.kirsher@intel.com, fweisbec@gmail.com,
	schwidefsky@de.ibm.com, linux@arm.linux.org.uk,
	paulmck@linux.vnet.ibm.com, torvalds@linux-foundation.org,
	mingo@kernel.org, Adam Nielsen <a.nielsen@shikadi.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54653ABF.3080400@gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexander Duyck <alexander.duyck@gmail.com> :
> On 11/13/2014 01:30 PM, Francois Romieu wrote:
> > Alexander Duyck <alexander.h.duyck@redhat.com> :
> > [...]
> >> In addition the r8169 uses a rmb() however I believe it is placed incorrectly
> >> as I assume it supposed to be ordering descriptor reads after the check for
> >> ownership.
> > Not exactly. It's a barrier against compiler optimization from 2004.
> > It should not matter.
> 
> Okay.  Do you recall the kind of problem it was you were seeing ?

Mildly, I had to grep the local archives.

The relevant code used to be included in the irq handler at that time
(napi support for this driver took place in may 2004). One did not want
a runaway loop in the Tx reaper.

Compiler optimization was suggested by Manfred Spraul in the thread below:
http://marc.info/?l=linux-kernel&m=108096868119004

> The origin of the rmb() for the Intel drivers was a PowerPC issue in
> which it was fetching the length of a buffer before it checked the DD
> bit (equivalent of DescOwn).  I'm wondering if the issue you were seeing
> was something similar where it had reordered reads in the descriptor to
> cause that type of result.

The problem was only reported on Intel 32 bit + slackware + gcc 3.2.3.

Adam Nielsen - Cc: added - did not return for this bug.

-- 
Ueimor
