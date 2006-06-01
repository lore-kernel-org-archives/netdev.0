From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: DPRINTKs in e1000 code (2.6.x kernels)
Date: Thu, 01 Jun 2006 15:08:10 -0700
Message-ID: <447F654A.3040406@intel.com>
References: <447D5B51.7030100@in.ibm.com>	 <23630a870399173fdc21603d9300d905@localhost> <1149199027.7160.22.camel@amitarora.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <sofar@foo-projects.org>, netdev@vger.kernel.org,
	amitarora@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:46266 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750706AbWFAWI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 18:08:29 -0400
To: Amit Arora <aarora@in.ibm.com>
In-Reply-To: <1149199027.7160.22.camel@amitarora.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amit Arora wrote:
> On Wed, 2006-05-31 at 16:30, Auke Kok wrote:
>> On Wed, 31 May 2006 14:31:05 +0530, Amit K Arora <aarora@in.ibm.com> wrote:
>>> Should these DPRINTKs be removed from the 2.6.x e1000 code as well ?
>> they already are. the patch was merged in 7.0.38-k2 or so which is over a month ago. 
> 
> I do not think these DPRINTKs have been removed from the latest code.
> Or, they did get removed at some point of time, but somehow again got
> added.
> I checked in 2.16.17-rc4 kernel, and also in the following versions of
> e1000 codebase (pulled from
> git://lost.foo-projects.org/~ahkok/git/netdev-2.6):
> e1000-7.0.38-k1, -k2 ... -k5  
> e1000-7.0.41
> 
> All of the above versions have the concerned DPRINTKs in e1000_suspend()
> and other routines.
> 
> Please check once and let me know if I am missing something. Thanks!

git-show d0e027db7861ef03de0ac08494a9a61984d8f8b0

it's really in there - please use jgarzik's netdev#upstream branch. Not sure 
if it already made it to 2.16.17-rc5, but I don't think this made it into 
2.16.17-rc4, so that is where you may be missing it.

Auke

---
ref.:

diff-tree d0e027db7861ef03de0ac08494a9a61984d8f8b0 (from 
a145410dccdb44f81d3b56763ef9b6f721f4e47c)
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Fri Apr 14 19:04:40 2006 -0700

     e1000: Remove PM warning DPRINTKs breaking 2.4.x kernels

     remove DPRINTKs that were printing warnings about power management on
     2.4 kernels.  Since we really don't react differently these printk
     statements are not needed.  This code was originally added to fix
     some compile time warnings that got fixed by newer kernels.


     Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
     Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
     Signed-off-by: John Ronciak <john.ronciak@intel.com>


diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index add8dc4..ac1e838 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4515,21 +4515,13 @@ e1000_suspend(struct pci_dev *pdev, pm_m

                 E1000_WRITE_REG(&adapter->hw, WUC, E1000_WUC_PME_EN);
                 E1000_WRITE_REG(&adapter->hw, WUFC, wufc);
-               retval = pci_enable_wake(pdev, PCI_D3hot, 1);
-               if (retval)
-                       DPRINTK(PROBE, ERR, "Error enabling D3 wake\n");
-               retval = pci_enable_wake(pdev, PCI_D3cold, 1);
-               if (retval)
-                       DPRINTK(PROBE, ERR, "Error enabling D3 cold wake\n");
+               pci_enable_wake(pdev, PCI_D3hot, 1);
+               pci_enable_wake(pdev, PCI_D3cold, 1);
         } else {
                 E1000_WRITE_REG(&adapter->hw, WUC, 0);
                 E1000_WRITE_REG(&adapter->hw, WUFC, 0);
-               retval = pci_enable_wake(pdev, PCI_D3hot, 0);
-               if (retval)
-                       DPRINTK(PROBE, ERR, "Error enabling D3 wake\n");
-               retval = pci_enable_wake(pdev, PCI_D3cold, 0);
-               if (retval)
-                       DPRINTK(PROBE, ERR, "Error enabling D3 cold wake\n");
+               pci_enable_wake(pdev, PCI_D3hot, 0);
+               pci_enable_wake(pdev, PCI_D3cold, 0);
         }

         if (adapter->hw.mac_type >= e1000_82540 &&
@@ -4538,13 +4530,8 @@ e1000_suspend(struct pci_dev *pdev, pm_m
                 if (manc & E1000_MANC_SMBUS_EN) {
                         manc |= E1000_MANC_ARP_EN;
                         E1000_WRITE_REG(&adapter->hw, MANC, manc);
-                       retval = pci_enable_wake(pdev, PCI_D3hot, 1);
-                       if (retval)
-                               DPRINTK(PROBE, ERR, "Error enabling D3 wake\n");
-                       retval = pci_enable_wake(pdev, PCI_D3cold, 1);
-                       if (retval)
-                               DPRINTK(PROBE, ERR,
-                                       "Error enabling D3 cold wake\n");
+                       pci_enable_wake(pdev, PCI_D3hot, 1);
+                       pci_enable_wake(pdev, PCI_D3cold, 1);
                 }
         }

@@ -4554,9 +4541,7 @@ e1000_suspend(struct pci_dev *pdev, pm_m

         pci_disable_device(pdev);

-       retval = pci_set_power_state(pdev, pci_choose_state(pdev, state));
-       if (retval)
-               DPRINTK(PROBE, ERR, "Error in setting power state\n");
+       pci_set_power_state(pdev, pci_choose_state(pdev, state));

         return 0;
  }
@@ -4567,22 +4552,15 @@ e1000_resume(struct pci_dev *pdev)
  {
         struct net_device *netdev = pci_get_drvdata(pdev);
         struct e1000_adapter *adapter = netdev_priv(netdev);
-       int retval;
         uint32_t manc, ret_val;

-       retval = pci_set_power_state(pdev, PCI_D0);
-       if (retval)
-               DPRINTK(PROBE, ERR, "Error in setting power state\n");
+       pci_set_power_state(pdev, PCI_D0);
         e1000_pci_restore_state(adapter);
         ret_val = pci_enable_device(pdev);
         pci_set_master(pdev);

-       retval = pci_enable_wake(pdev, PCI_D3hot, 0);
-       if (retval)
-               DPRINTK(PROBE, ERR, "Error enabling D3 wake\n");
-       retval = pci_enable_wake(pdev, PCI_D3cold, 0);
-       if (retval)
-               DPRINTK(PROBE, ERR, "Error enabling D3 cold wake\n");
+       pci_enable_wake(pdev, PCI_D3hot, 0);
+       pci_enable_wake(pdev, PCI_D3cold, 0);

         e1000_reset(adapter);
         E1000_WRITE_REG(&adapter->hw, WUS, ~0);

