From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: Re: [PATCH] igb in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 20:59:18 +0800
Message-ID: <001201d01c54$c4a395b0$4deac110$@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux.nics@intel.com
To: "'Jeff Kirsher'" <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Language: zh-cn
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Thank for the reply!

For the first reply:
I let some functions fail on purpose to test error handling code, and then run the driver in reality as well as monitor the function calls in runtime.
The results are in my report. 

For the second reply:
I admit you are right, and my code style need to be improved.

On Sat, 2014-12-20 at 16:11 +0800, Jia-Ju Bai wrote:
> I have actually tested igb driver on the real hardware(Intel 82575EB 
> PCI-E Gigabit Ethernet Controller), and find some potential bugs:
> The target file is drivers/net/ethernet/intel/igb/igb_main.c
> 
> (1) In the normal process of igb, pci_enable_pcie_error_reporting and 
> pci_disable_pcie_error_reporting is called in pairs in igb_probe and 
> igb_remove. However, when pci_enable_pcie_error_reporting has been 
> called and alloc_etherdev_mqs in igb_probe is failed, 
> "err_alloc_etherdev"
> segment
> in igb_probe is executed immediately to exit, but 
> pci_disable_pcie_error_reporting is not called.
> (2) The same situation happens when pci_iomap in igb_probe is failed.
> (3) The same situation happens when igb_sw_init in igb_probe is 
> failed.
> (4) The same situation happens when register_netdev in igb_probe is 
> failed.
> (5) The same situation happens when igb_init_i2c in igb_probe is 
> failed.
> 
> (6) The function kcalloc is called by igb_sw_init when initializing 
> the ethernet card driver, but kfree is not called when register_netdev 
> in igb_probe is failed, which may cause memory leak.
> (7) The same situation happens when igb_init_i2c in igb_probe is 
> failed.
> (8) The same situation happens when kzalloc in igb_alloc_q_vector is 
> failed.
> (9) The same situation happens when igb_alloc_q_vector in 
> igb_alloc_q_vectors is failed.
> 
> (10) When igb_init_i2c in igb_probe is failed, igb_enable_sriov is 
> called in igb_probe_vfs, but igb_disable_sriov is not called.
> (11) The same situation with [10] happens when register_netdev in 
> igb_probe is failed.
> 
> Meanwhile, I also write the patch to fix the bugs. I have run the 
> patch on the hardware, it can work normally and fix the above bugs.

>Was this a bug you actually saw?  Or a theoretical bug based on code review?

>I do not mind adding this to my queue so that we can review and test the patch, although this will cause a fair amount of regression testing.



------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=164703151&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
