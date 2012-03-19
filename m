From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: VLAN regression caused by: e1000: do vlan cleanup
	(799d531).
Date: Mon, 19 Mar 2012 14:08:36 +0100
Message-ID: <20120319130836.GD2192@minipsycho.brq.redhat.com>
References: <4F5E3DCF.6010307@candelatech.com>
	<20120313095942.GC2239@minipsycho.brq.redhat.com>
	<4F5F9582.60501@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel list <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <4F5F9582.60501@candelatech.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Tue, Mar 13, 2012 at 07:44:18PM CET, greearb@candelatech.com wrote:
>On 03/13/2012 02:59 AM, Jiri Pirko wrote:
>>Mon, Mar 12, 2012 at 07:17:51PM CET, greearb@candelatech.com wrote:
>>>This commit breaks 802.1Q VLANs on my e1000 NIC, and it remains broken in top-of-tree
>>>(as of 2 days ago, at least).
>>>
>>>commit 5622e4044a916de1af84bfcc4d437ce0c799d531
>>>Author: Jiri Pirko<jpirko@redhat.com>
>>>Date:   Thu Jul 21 03:26:31 2011 +0000
>>>
>>>    e1000: do vlan cleanup
>>>
>>>    - unify vlan and nonvlan rx path
>>>    - kill adapter->vlgrp and e1000_vlan_rx_register
>>>    - allow to turn on/off rx/tx vlan accel via ethtool (set_features)
>>>
>>>    Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>>    Signed-off-by: David S. Miller<davem@davemloft.net>
>>>
>>>
>>>My OS is RH 8, 32-bit.
>>>
>>>My e1000 hardware is:
>>>
>>>05:01.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
>>>	Subsystem: Intel Corporation PRO/1000 MT Dual Port Server Adapter
>>>	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
>>>	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium>TAbort-<TAbort-<MAbort->SERR-<PERR- INTx-
>>>	Latency: 52 (63750ns min), Cache Line Size: 32 bytes
>>>	Interrupt: pin A routed to IRQ 24
>>>	Region 0: Memory at d8100000 (64-bit, non-prefetchable) [size=128K]
>>>	Region 4: I/O ports at 3000 [size=64]
>>>	Capabilities: [dc] Power Management version 2
>>>		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>>>		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>>>	Capabilities: [e4] PCI-X non-bridge device
>>>		Command: DPERE- ERO+ RBC=512 OST=1
>>>		Status: Dev=05:01.0 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
>>>	Capabilities: [f0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
>>>		Address: 0000000000000000  Data: 0000
>>>	Kernel driver in use: e1000
>>>	Kernel modules: e1000
>>>
>>>05:01.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
>>>	Subsystem: Intel Corporation PRO/1000 MT Dual Port Server Adapter
>>>	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
>>>	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium>TAbort-<TAbort-<MAbort->SERR-<PERR- INTx-
>>>	Latency: 52 (63750ns min), Cache Line Size: 32 bytes
>>>	Interrupt: pin B routed to IRQ 25
>>>	Region 0: Memory at d8120000 (64-bit, non-prefetchable) [size=128K]
>>>	Region 4: I/O ports at 3040 [size=64]
>>>	Capabilities: [dc] Power Management version 2
>>>		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>>>		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>>>	Capabilities: [e4] PCI-X non-bridge device
>>>		Command: DPERE- ERO+ RBC=512 OST=1
>>>		Status: Dev=05:01.1 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
>>>	Capabilities: [f0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
>>>		Address: 0000000000000000  Data: 0000
>>>	Kernel driver in use: e1000
>>>	Kernel modules: e1000
>>>
>>>
>>>I'm attaching ethregs output from good and bad kernels, in case that helps.
>>>
>>>The symptom is that pkts show up as 'ISL' instead of Ethernet frames.  I'm
>>>including a capture of that as well.  I am sending UDP pkts from one NIC to the other,
>>>on vlan 8, though because ARP fails, no UDP is ever sent.  The sniff shows rcvd pkts
>>>as looking funky, but it could be they are transmitted badly once they hit the NIC,
>>>so I don't know if it's actually rx or tx (or both) logic that is busted at this point.
>>>
>>>I'm using routing rules to make send-to-self work, but the kernel is un-patched.
>>>
>>>Please let me know if you need additional info.  I'll be happy to test patches,
>>>I have a good setup to reproduce this easily.
>>
>>Thanks for the report Ben.
>>
>>It would help it you try to enable/disable vlan hw accel by ethtool to
>>see if it helps.
>>
>>I have suspition that vlan filter must be on/offed along with vlan
>>accel.
>
>Ok, if I disable rx-vlan-hw-parse on both NICs, traffic starts working.
>
>And, if I re-enable rx-vlan-hw-parse on both NICs, it continues to work.
>
>Maybe the initialization logic needs some fixing?

Could you please try following patch?

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 6419a88..b06c31c 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -164,6 +164,8 @@ static int e1000_82547_fifo_workaround(struct e1000_adapter *adapter,
 static bool e1000_vlan_used(struct e1000_adapter *adapter);
 static void e1000_vlan_mode(struct net_device *netdev,
 			    netdev_features_t features);
+static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
+				     bool filter_on);
 static int e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
 static int e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
@@ -1214,7 +1216,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-	e1000_vlan_mode(netdev, netdev->features);
+	e1000_vlan_filter_on_off(adapter, false);
 
 	/* print bus type/speed/width info */
 	e_info(probe, "(PCI%s:%dMHz:%d-bit) %pM\n",
@@ -4772,6 +4774,22 @@ static bool e1000_vlan_used(struct e1000_adapter *adapter)
 	return false;
 }
 
+static void __e1000_vlan_mode(struct e1000_adapter *adapter,
+			      netdev_features_t features)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 ctrl;
+
+	ctrl = er32(CTRL);
+	if (features & NETIF_F_HW_VLAN_RX) {
+		/* enable VLAN tag insert/strip */
+		ctrl |= E1000_CTRL_VME;
+	} else {
+		/* disable VLAN tag insert/strip */
+		ctrl &= ~E1000_CTRL_VME;
+	}
+	ew32(CTRL, ctrl);
+}
 static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
 				     bool filter_on)
 {
@@ -4781,6 +4799,7 @@ static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
 
+	__e1000_vlan_mode(adapter, adapter->netdev->features);
 	if (filter_on) {
 		/* enable VLAN receive filtering */
 		rctl = er32(RCTL);
@@ -4801,24 +4820,14 @@ static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
 }
 
 static void e1000_vlan_mode(struct net_device *netdev,
-	netdev_features_t features)
+			    netdev_features_t features)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
-	u32 ctrl;
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
 
-	ctrl = er32(CTRL);
-	if (features & NETIF_F_HW_VLAN_RX) {
-		/* enable VLAN tag insert/strip */
-		ctrl |= E1000_CTRL_VME;
-	} else {
-		/* disable VLAN tag insert/strip */
-		ctrl &= ~E1000_CTRL_VME;
-	}
-	ew32(CTRL, ctrl);
+	__e1000_vlan_mode(adapter, features);
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_enable(adapter);

------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
