From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Wed, 13 Apr 2016 17:50:28 +1000
Message-ID: <20160413175028.5d3a4cf2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mark Rustad <mark.d.rustad@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Andrew Bowers <andrewx.bowers@intel.com>,
	Build bot for Mark Brown <broonie@kernel.org>,
	kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

[A report from Mark's buildbot]

After merging the net-next tree, today's linux-next build (arm
allmodconfig) failed like thisi (this has actually been failing for a
few days, now):

ERROR: "__bad_udelay" [drivers/net/ethernet/intel/ixgbe/ixgbe.ko] undefined!

Caused by commit

  49425dfc7451 ("ixgbe: Add support for x550em_a 10G MAC type")

arm only allows udelay()s up to 2 milliseconds.  This commit
adds a 5 ms udelay in ixgbe_acquire_swfw_sync_x550em_a() in
drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c.

-- 
Cheers,
Stephen Rothwell
