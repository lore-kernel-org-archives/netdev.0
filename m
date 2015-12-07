From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Use __vmalloc with GFP_ATOMIC for table allocation
Date: Mon, 07 Dec 2015 14:29:53 -0500 (EST)
Message-ID: <20151207.142953.387889541116696974.davem@davemloft.net>
References: <20151204181555.GC29598@orbit.nwl.cc>
	<20151205070603.GB23255@gondor.apana.org.au>
	<20151207153524.GA22032@pox.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, phil@nwl.cc, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: tgraf@suug.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151207153524.GA22032@pox.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 7 Dec 2015 16:35:24 +0100

> Did you look into what __vmalloc prevents to work with BH disabled?

You can't issue the cross-cpu TLB flushes from atomic contexts.
It's the kernel page table updates that create the restriction.
