From: "Guenther Thomsen" <GThomsen@bluearc.com>
Subject: RE: kernel panic (on DHCP discover?) in sky2 driver of 2.6.17-rc1
Date: Wed, 7 Jun 2006 12:33:21 -0700
Message-ID: <CECD6E8A589E8447BC6E836C8369AFF506828728@us-email.terastack.bluearc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "John W. Linville" <linville@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmimesweeper.bluearc.com ([63.203.197.133]:37392 "EHLO
	us-mimesweeper.terastack.bluearc.com") by vger.kernel.org with ESMTP
	id S932373AbWFGTdY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 15:33:24 -0400
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was perhaps a bit quick to declare victory. While the results below stand and the machine survived the last few days (idle), it occurred to me only today, to have a look at the kernel's message buffer, where I found following:
--8<--
sky2 eth0: enabling interface
sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control none
sky2 eth1: enabling interface
sky2 eth1: Link is up at 1000 Mbps, full duplex, flow control none
audit(1149379670.514:3): audit_pid=1915 old=0 by auid=4294967295
<unknown>: hw csum failure.
sky2 eth1: rx error, status 0x7ffc0001 length 444

Call Trace: <ffffffff811de741>{__skb_checksum_complete+76}
       <ffffffff812030cb>{__tcp_checksum_complete_user+33}
       <ffffffff812080d8>{tcp_rcv_established+817} <ffffffff8120f3ee>{tcp_v4_
do_rcv+43}
       <ffffffff811da2ee>{sk_wait_data+203} <ffffffff811fe5a8>{tcp_prequeue_p
rocess+121}
       <ffffffff811ff71d>{tcp_recvmsg+1104} <ffffffff811d9712>{sock_common_re
cvmsg+48}
       <ffffffff811d7d4f>{do_sock_read+209} <ffffffff811d7e7e>{sock_aio_read+
83}
       <ffffffff811e2ca1>{dev_queue_xmit+0} <ffffffff8106dce9>{do_sync_read+1
99}
       <ffffffff8103d699>{remove_wait_queue+18} <ffffffff8103d530>{autoremove
_wake_function+0}
       <ffffffff8106df83>{vfs_read+228} <ffffffff8106ea12>{sys_read+69}
       <ffffffff81009b0d>{tracesys+209}
<unknown>: hw csum failure.
sky2 eth1: rx error, status 0x7ffc0001 length 444


Call Trace: <ffffffff811de741>{__skb_checksum_complete+76}
       <ffffffff812030cb>{__tcp_checksum_complete_user+33}
       <ffffffff812080d8>{tcp_rcv_established+817} <ffffffff8120f3ee>{tcp_v4_
do_rcv+43}
       <ffffffff811da2ee>{sk_wait_data+203} <ffffffff811fe5a8>{tcp_prequeue_p
rocess+121}
       <ffffffff811ff71d>{tcp_recvmsg+1104} <ffffffff811d9712>{sock_common_re
cvmsg+48}
       <ffffffff811d7696>{alloc_sock_iocb+20} <ffffffff811d7d4f>{do_sock_read
+209}
       <ffffffff811d7e7e>{sock_aio_read+83} <ffffffff8106dce9>{do_sync_read+1
99}
       <ffffffff8103d699>{remove_wait_queue+18} <ffffffff8103d530>{autoremove
_wake_function+0}
       <ffffffff8106df83>{vfs_read+228} <ffffffff8106ea12>{sys_read+69}
       <ffffffff81009b0d>{tracesys+209}
<unknown>: hw csum failure.
sky2 eth1: rx error, status 0x7ffc0001 length 444


Call Trace: <ffffffff811de741>{__skb_checksum_complete+76}
       <ffffffff812030cb>{__tcp_checksum_complete_user+33}
       <ffffffff812080d8>{tcp_rcv_established+817} <ffffffff8120f3ee>{tcp_v4_
do_rcv+43}
       <ffffffff811da2ee>{sk_wait_data+203} <ffffffff811fe5a8>{tcp_prequeue_p
rocess+121}
       <ffffffff811ff71d>{tcp_recvmsg+1104} <ffffffff811d9712>{sock_common_re
cvmsg+48}
       <ffffffff811d7d4f>{do_sock_read+209} <ffffffff811d7e7e>{sock_aio_read+
83}
       <ffffffff8106dce9>{do_sync_read+199} <ffffffff8103d699>{remove_wait_qu
eue+18}
       <ffffffff8103d530>{autoremove_wake_function+0} <ffffffff8102f1a0>{curr
ent_kernel_time+13}
       <ffffffff8106df83>{vfs_read+228} <ffffffff8106ea12>{sys_read+69}
       <ffffffff81009b0d>{tracesys+209}

sky2 eth0: rx error, status 0x7ffc0001 length 444
sky2 eth0: rx error, status 0x7ffc0001 length 444
sky2 eth1: rx error, status 0x7ffc0001 length 444
sky2 eth1: rx error, status 0x7ffc0001 length 444
sky2 eth1: rx error, status 0x7ffc0001 length 444
-->8--
Looks, like we're almost, but not quite there yet.

cheers
    Guenther


-----Original Message-----
From: Guenther Thomsen 
Sent: Saturday, June 03, 2006 9:06 PM
To: 'Stephen Hemminger'
Cc: John W. Linville; netdev@vger.kernel.org
Subject: RE: kernel panic (on DHCP discover?) in sky2 driver of
2.6.17-rc1


I received the hardware back and took the opportunity to test with 2.6.17-rc5-git11. So far I did only little tests (ttcp on both interfaces in, out or mixed with some 10e6 packets), but it looks good. No errors (well, 16 overruns in 76574513 packets) and line rate (about 111MB/s) on both channels simultaneously. Hurray!

Thanks a lot for you continued efforts.
	Guenther

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@osdl.org]
Sent: Tuesday, May 16, 2006 12:12 PM
To: Guenther Thomsen
Cc: John W. Linville; netdev@vger.kernel.org
Subject: Re: kernel panic (on DHCP discover?) in sky2 driver of
2.6.17-rc1


Could you try the 2.6.17-rc4 version with this patch. It turns out the board
seems to give out of order status responses.

Ignore the vendor sk98lin driver, when I try the stock version it spends it's
life resetting itself because it sets up PCI bus wrong. If I fix that, it spends
it's time getting confused because it can't handle intermixed status reports
properly (checksum et all is per port not per board).


 drivers/net/sky2.c |   28 +++++++++++++++++++++-------
 1 files changed, 21 insertions(+), 7 deletions(-)

792547bc5e8e4f7d5a1070a168056f429635c254
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index ffd267f..11e7914 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1020,8 +1020,27 @@ static int sky2_up(struct net_device *de
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
 	u32 ramsize, rxspace, imask;
-	int err = -ENOMEM;
+	int cap, err;
+	struct net_device *otherdev = hw->dev[sky2->port^1];
 
+	/*
+	 * Reduce split transactions (and turn off) rx checksums to
+	 * prevent problems with dual ports.
+	 */
+	if (otherdev && netif_running(otherdev) &&
+	    (cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PCIX))) {
+		struct sky2_port *osky2 = netdev_priv(otherdev);
+		u16 cmd;
+
+		cmd = sky2_pci_read16(hw, cap + PCI_X_CMD);
+		cmd &= ~PCI_X_CMD_MAX_SPLIT;
+		sky2_pci_write16(hw, cap + PCI_X_CMD, cmd);
+
+		sky2->rx_csum = 0;
+		osky2->rx_csum = 0;
+	}
+
+	err = -ENOMEM;
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
 
@@ -3067,12 +3086,7 @@ static __devinit struct net_device *sky2
 	sky2->duplex = -1;
 	sky2->speed = -1;
 	sky2->advertising = sky2_supported_modes(hw);
-
-	/* Receive checksum disabled for Yukon XL
-	 * because of observed problems with incorrect
-	 * values when multiple packets are received in one interrupt
-	 */
-	sky2->rx_csum = (hw->chip_id != CHIP_ID_YUKON_XL);
+	sky2->rx_csum = 1;
 
 	spin_lock_init(&sky2->phy_lock);
 	sky2->tx_pending = TX_DEF_PENDING;
-- 
1.2.4

