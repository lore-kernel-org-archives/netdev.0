From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: igb regression (interface hang) with latest -git
Date: Wed, 21 Jan 2009 23:22:14 +0100
Message-ID: <200901212322.14875.rjw@sisk.pl>
References: <20090121102840.GA24967@elte.hu> <200901212234.42749.rjw@sisk.pl>
	<20090121214810.GB27665@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090121214810.GB27665@elte.hu>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wednesday 21 January 2009, Ingo Molnar wrote:
> 
> * Rafael J. Wysocki <rjw@sisk.pl> wrote:
> 
> > On Wednesday 21 January 2009, Ingo Molnar wrote:
> > > 
> > > * Ingo Molnar <mingo@elte.hu> wrote:
> > > 
> > > > > One other piece of info (in addition to what Bruce requested) that 
> > > > > would be useful is after you've done ifconfig eht0 up, cat 
> > > > > /proc/interrupts | grep eth0 and send that output (I want to see your 
> > > > > MSI-X configuration).
> > > > 
> > > > here it is:
> > > > 
> > > >  79:         35          0       9836       7451       1197       1360        766          0       2196        995        770          0       2051        863       4714       1879   PCI-MSI-edge      eth0-tx-0
> > > >  80:       2335          0       2718       3651       5024       9850        533          0       1405       1095          0          0       4421       1229          0       2002   PCI-MSI-edge      eth0-tx-1
> > > >  81:         33          0          0       5478       1125       6585       4865       6306          0          0          0        714       3757          0       2662       1020   PCI-MSI-edge      eth0-tx-2
> > > >  82:         21       1428       3136       3783       4249       6833          0          0       4175          0          0       1465       1940       1780       6286          0   PCI-MSI-edge      eth0-tx-3
> > > >  83:         40          0          0       4788          0       1486          0       7185       3998       8637       1409       6785          0          0          0      10060   PCI-MSI-edge      eth0-rx-0
> > > >  84:         70       1441       2606       1342          0       1678       4301       1839          0       6507       6910      16470          0       1484       1004          0   PCI-MSI-edge      eth0-rx-1
> > > >  85:         40       1368          0       3560       5022       2040          5       1719          0       2037        956         40          0      17264       6456       2833   PCI-MSI-edge      eth0-rx-2
> > > >  86:         44        414          5       1164         30       4513       4595       1542          0      10033       1151          0       4961       4203          0      10703   PCI-MSI-edge      eth0-rx-3
> > > >  87:          1          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth0
> > > 
> > > btw., i turned off CONFIG_PCI_MSI and that worked around the interface 
> > > hang - the box has 40 minutes uptime now and still no hang. (it would hang 
> > > within 5 minutes previously)
> > > 
> > > can test the revert of any of these commits:
> > > 
> > > e42e4ba: igb: fix anoying type mismatch warning on rx/tx queue sizing
> > > 8d25332: igb: Fix build warning when DCA is disabled.
> > > 26bc19e: igb: re-order queues to support cleaner use of ivar on 82576
> > > 0e014cb: igb: defeature tx head writeback
> > > 678c610: drivers/net/igb: remove dead code (function 'igb_read_pci_cfg')
> > > 908a7a1: net: Remove unused netdev arg from some NAPI interfaces.
> > > ea943d4: igb: fixup AER with proper error handling
> > > 5e8427e: igb: Correctly determine pci-e function number in virtual environment
> > > b4557be: igb: update handling of RCTL for smaller buffer sizes
> > > cb7b48f: igb/e1000e: Naming interrupt vectors
> > > 40a914f: igb: Add support for pci-e Advanced Error Reporting
> > > 527d47c: igb: link up/down messages must follow a specific format
> > > 5b9ab2e: Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
> > > 69d728b: igb: loopback bits not correctly cleared from RCTL register
> > > 9b07f3d: igb: remove unneeded bit refrence when enabling jumbo frames
> > > f5f4cf0: igb: do not use phy ops in ethtool test cleanup for non-copper parts
> > > 0082982: netdev: add more functions to netdevice ops
> > > 68fd991: igb: Fix tx/rx_ring_count parameters for igb on suspend/resume/ring resize
> > > b2d5653: igb: simplify swap in clean_rx_irq if using packet split
> > > 2e5c692: igb: convert to net_device_ops
> > > 198d6ba: Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
> > > 4cf1653: netdevice: safe convert to netdev_priv() #part-2
> > > babcda7: drivers/net: Kill now superfluous ->last_rx stores.
> > > 7c510e4: net: convert more to %pM
> > > 
> > > i had a quick look at all of them but none seem to have a direct 
> > > connection to MSI-X interrupt generation.
> > > 
> > > There's a couple of ones that could have side effects:
> > > 
> > > Maybe this one:
> > > 
> > >   26bc19e: igb: re-order queues to support cleaner use of ivar on 82576
> > > 
> > > due to its sheer commit size and due to its impact on the hw programming.
> > > 
> > > or:
> > > 
> > >   0e014cb: igb: defeature tx head writeback
> > > 
> > > Might have some side-effect on tx-completion IRQs and might tickle 
> > > firmware bugs?
> > > 
> > > Or:
> > > 
> > >   5e8427e: igb: Correctly determine pci-e function number in virtual environment
> > > 
> > > while it should have no impact on a native kernel, it does change the PCI 
> > > config space access sequences.
> > > 
> > > Or maybe:
> > > 
> > >   69d728b: igb: loopback bits not correctly cleared from RCTL register
> > > 
> > > as this impacts the PCI programming too.
> > > 
> > > But ... i dont really know this code so i'm guessing around.
> > 
> > Well, AER (Advanced Error Reporting) is currently broken w/ MSI-X, so maybe
> > this one:
> > 
> > 40a914f: igb: Add support for pci-e Advanced Error Reporting
> 
> ah, yeah, that makes sense. I discarded that commit because i was unsure 
> whether this box has AER and the boot log said:
> 
>  calling  aer_service_init+0x0/0x20 @ 1
>  initcall aer_service_init+0x0/0x20 returned 0 after 61 usecs
> 
> shouldnt it have printed something if AER was available?

The driver doesn't seem to print anything on success as far as I can see.
It only reports faliures, apparently.

Thanks,
Rafael

------------------------------------------------------------------------------
This SF.net email is sponsored by:
SourcForge Community
SourceForge wants to tell your story.
http://p.sf.net/sfu/sf-spreadtheword
