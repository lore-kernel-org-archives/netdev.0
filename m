From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] pci, e1000e: Add and use __pci_disable_link_state
Date: Mon, 9 May 2011 14:35:36 -0700
Message-ID: <20110509143536.08bd0297@jbarnes-desktop>
References: <4DC6E6E8.9040306@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	Matthew Garrett <mjg@redhat.com>,
	Naga Chumbalkar <nagananda.chumbalkar@hp.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <4DC6E6E8.9040306@kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 08 May 2011 11:54:32 -0700
Yinghai Lu <yinghai@kernel.org> wrote:

> 
> Need to use it in _e1000e_disable_aspm.
> when aer happens,
> pci_walk_bus already have down_read(&pci_bus_sem)...
> then report_slot_reset
>         ==> e1000_io_slot_reset
>                 ==> e1000e_disable_aspm
>                         ==> pci_disable_link_state...
> 
> We can not use pci_disable_link_state, and it will try to hold pci_bus_sem again.
> 
> Try to have __pci_disable_link_state that will not need to hold pci_bus_sem.

What about the other callers of e1000e_disable_aspm?  Do they already
have the lock held or is it just reset that needs the already locked
version?

> +extern void __pci_disable_link_state(struct pci_dev *pdev, int state);
>  extern void pcie_clear_aspm(void);
>  extern void pcie_no_aspm(void);
>  #else

pci_disable_link_state_locked would be more descriptive and would match
other usage in the kernel.

Thanks,

-- 
Jesse Barnes, Intel Open Source Technology Center
