From: Dave Hansen <dave@sr71.net>
Subject: Re: [PATCH] e1000: fix e1000e_disable_aspm_locked() warning
Date: Mon, 28 Sep 2015 08:57:18 -0700
Message-ID: <5609635E.6010907@sr71.net>
References: <20150831212641.FA5D579A@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: dave.hansen@linux.intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: raanan.avargil@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150831212641.FA5D579A@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/31/2015 02:26 PM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> I have a .config with CONFIG_PM disabled.  I get the following whenever
> compiling the e1000 driver:
> 
> ...net/ethernet/intel/e1000e/netdev.c:6450:13: warning: 'e1000e_disable_aspm_locked' defined but not used [-Wunused-function]
>  static void e1000e_disable_aspm_locked(struct pci_dev *pdev, u16 state)
> 
> Looks like we just need to move e1000e_disable_aspm_locked() to
> be underneath the CONFIG_PM #ifdef.

This patch:

	[2758f9edb]: e1000e: Fix incorrect ASPM locking

established a new caller for e1000e_disable_aspm_locked() which makes my
patch useless and wrong (it breaks the compile).

I believe we should just revert my patch.
