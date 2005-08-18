From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] struct file cleanup : the very large file_ra_state is now allocated only on demand.
Date: Thu, 18 Aug 2005 04:57:28 +0200
Message-ID: <20050818025727.GY3996@wotan.suse.de>
References: <20050810164655.GB4162@linux.intel.com> <20050810.135306.79296985.davem@davemloft.net> <20050810211737.GA21581@linux.intel.com> <430391F1.9080900@cosmosbay.com> <20050817211829.GK27628@wotan.suse.de> <4303AEC4.3060901@cosmosbay.com> <20050817215357.GU3996@wotan.suse.de> <4303D90E.2030103@cosmosbay.com> <20050818010524.GW3996@wotan.suse.de> <4303F7E8.5030705@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Eric Dumazet <dada1@cosmosbay.com>,
	Benjamin LaHaise <bcrl@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932115AbVHRC5e@vger.kernel.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Content-Disposition: inline
In-Reply-To: <4303F7E8.5030705@yahoo.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> You don't want to always have bad performance though, so you
> could attempt to allocate if either the pointer is null _or_ it
> points to the global structure?

Remember it's after a GFP_KERNEL OOM. If that fails most likely
you have deadlocked somewhere else already because Linux's handling
of that is so bad. Suboptimal readahead somewhere is the smallest
of your problems.

-Andi
