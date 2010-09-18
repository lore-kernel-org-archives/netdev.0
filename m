From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] Gigabit Ethernet driver of Topcliff PCH
Date: Fri, 17 Sep 2010 23:08:46 -0700 (PDT)
Message-ID: <20100917.230846.226755853.davem@davemloft.net>
References: <4C90CBC9.7000203@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, john.linn@xilinx.com, ralf@linux-mips.org,
	kristoffer@gaisler.com, mbizon@freebox.fr,
	gregory.v.rose@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl,
	okada533@dsn.okisemi.com, shimizu394@dsn.okisemi.com,
	morinaga526@dsn.okisemi.com, qi.wang@intel.com,
	yong.y.wang@intel.com, andrew.chih.howe.khor@intel.com,
	joel.clark@intel.com, margie.foster@intel.com,
	arjan@linux.intel.com
To: masa-korg@dsn.okisemi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C90CBC9.7000203@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Date: Wed, 15 Sep 2010 22:36:09 +0900

> +struct pch_gbe_regs_mac_adr {
> +	u32 high;
> +	u32 low;
> +} __attribute__ ((packed));;
 ...
> +struct pch_gbe_regs {
 ...
> +} __attribute__ ((packed));
...
> +struct pch_gbe_rx_desc {
 ...
> +} __attribute__ ((packed));;
 ...
> +struct pch_gbe_tx_desc {
 ...
> +} __attribute__ ((packed));;

The packed attribute should not be necessary for any of these
datastructures, so unless you can prove they are needed please
remove the attribute tag.

Besides being unnecessary, it will make cpu access to these
descriptors extremely slow on risc cpus, as the compiler will
emit byte-at-a-time accesses for all members of the structure
larger than one byte.
