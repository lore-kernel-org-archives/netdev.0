From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Sun, 17 Apr 2016 11:47:20 +0200
Message-ID: <4480650.3kf9R6iZAS@wuerfel>
References: <20160413175028.5d3a4cf2@canb.auug.org.au> <20160413.111513.295841881765244758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	andrewx.bowers@intel.com, linaro-kernel@lists.linaro.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	mark.d.rustad@intel.com
To: kernel-build-reports@lists.linaro.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20160413.111513.295841881765244758.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 13 April 2016 11:15:13 David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 13 Apr 2016 17:50:28 +1000
> 
> > After merging the net-next tree, today's linux-next build (arm
> > allmodconfig) failed like thisi (this has actually been failing for a
> > few days, now):
> > 
> > ERROR: "__bad_udelay" [drivers/net/ethernet/intel/ixgbe/ixgbe.ko] undefined!
> > 
> > Caused by commit
> > 
> >   49425dfc7451 ("ixgbe: Add support for x550em_a 10G MAC type")
> > 
> > arm only allows udelay()s up to 2 milliseconds.  This commit
> > adds a 5 ms udelay in ixgbe_acquire_swfw_sync_x550em_a() in
> > drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c.
> 
> Jeff, please have your folks look into this.  Probably just a simple
> conversion to mdelay().
> 

I sent a patch, pretty sure we can use msleep() here rather than
a wasteful mdelay().

	Arnd
