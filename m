From: Joe Jin <joe.jin@oracle.com>
Subject: Re: Broadcom 5709 take long time to bring up
Date: Thu, 19 Aug 2010 16:11:15 +0800
Message-ID: <20100819081115.GA6419@joejin-pc.cn.oracle.com>
References: <20100818143432.GA29386@joejin-pc.cn.oracle.com> <1282147735.3880.83.camel@localhost> <20100819011350.GB412@joejin-pc.cn.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Li <benli@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	"terry.liu@oracle.com" <terry.liu@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:28486 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325Ab0HSIMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 04:12:49 -0400
Content-Disposition: inline
In-Reply-To: <20100819011350.GB412@joejin-pc.cn.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Just confirmed it, there was not iscsi configured on the server.

Thanks,
Joe


On 2010-08-19 09:13, Joe Jin wrote:
> Hi Benjamin,
> 
> Thanks for your reply, see the answers in the lines.
> 
> On 2010-08-18 09:08, Benjamin Li wrote:
> > Hi Joe,
> > 
> > Just a couple of quick questions:
> > 
> > 1.  It is possible that autonegotiation could take in the orders of
> > seconds depending on the remote partner.   Could you describe the remote
> > partner?
> 
> I dont think it caused that.
> >From system log(see below) could saw brought up the interface took
> around 3 seconds. I have add some debugging codes in the drivers and
> could saw 3 times poll the devices and all the state of device is
> link down.
> 
> Also, from system could found during bootup, brought all devices 
> took less than 1 seconds, but ifdown/ifup take long times.
> 
> > 
> > 2.  Are there iSCSI offload connections?  With iSCSI there is
> > additionial overhead to cleanup/setup iSCSI connections on the
> > chip/firmware when ifup'ing/ifdown'ing a network interface.
> 
> I'll confirm it later, but from system log saw have initialized 
> iSCSI module, it maybe cause it.
> 
> > 
> > 3.  Could you provide the kernel logs during this up/down test?  I
> > wanted to see if there was anything interesting in the kernel logs.
> > 
> 
> Here are kernel log:
> 
> 
> System log of bootup
> ~~~~~~~~~~~~~~~~~~~~
> Jul 19 11:23:28 bond-test kernel: Ethernet Channel Bonding Driver: v3.4.0 (October 7, 2008)
> Jul 19 11:23:28 bond-test kernel: bonding: Warning: updelay (150) is not a multiple of miimon (100), updelay rounded to 100 ms
> Jul 19 11:23:28 bond-test kernel: bonding: MII link monitoring set to 100 ms
> Jul 19 11:23:28 bond-test kernel: ADDRCONF(NETDEV_UP): bond0: link is not ready
> Jul 19 11:23:28 bond-test kernel: bonding: bond0: Adding slave eth0.
> Jul 19 11:23:28 bond-test kernel: bnx2: eth0: using MSI
> Jul 19 11:23:28 bond-test kernel: iscsi: registered transport (bcm570x-020000)
> Jul 19 11:23:28 bond-test kernel: bnx2i: netif=eth0, iscsi=bcm570x-020000
> Jul 19 11:23:28 bond-test kernel: bnx2i [02:00.00]: ISCSI_INIT passed
> Jul 19 11:23:28 bond-test kernel: bonding: bond0: enslaving eth0 as a backup interface with a down link.
> Jul 19 11:23:28 bond-test kernel: bonding: bond0: Adding slave eth1.
> Jul 19 11:23:28 bond-test kernel: bnx2: eth1: using MSI
> Jul 19 11:23:28 bond-test kernel: iscsi: registered transport (bcm570x-020001)
> Jul 19 11:23:28 bond-test kernel: bnx2i: netif=eth1, iscsi=bcm570x-020001
> Jul 19 11:23:28 bond-test kernel: bnx2i [02:00.01]: ISCSI_INIT passed
> Jul 19 11:23:28 bond-test kernel: bonding: bond0: enslaving eth1 as a backup interface with a down link.
> Jul 19 11:23:28 bond-test kernel: bnx2: eth1 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:23:28 bond-test kernel: bonding: bond0: link status up for interface eth1, enabling it in 0 ms.
> Jul 19 11:23:28 bond-test kernel: bonding: bond0: link status definitely up for interface eth1.
> Jul 19 11:23:28 bond-test kernel: bonding: bond0: making interface eth1 the new active one.
> Jul 19 11:23:28 bond-test kernel: bonding: bond0: first active interface up!
> Jul 19 11:23:28 bond-test kernel: ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
> Jul 19 11:23:28 bond-test kernel: bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:23:28 bond-test kernel: bonding: bond0: link status up for interface eth0, enabling it in 100 ms.
> Jul 19 11:23:28 bond-test kernel: bonding: bond0: link status definitely up for interface eth0.
> Jul 19 11:23:28 bond-test kernel: bonding: bond0: making interface eth0 the new active one.
> 
> 
> System log of the testcase
> ~~~~~~~~~~~~~~~~~~~~~~~~~~
> Jul 19 11:25:41 bond-test kernel: bonding: bond0: Removing slave eth0
> Jul 19 11:25:41 bond-test kernel: bonding: bond0: Warning: the permanent HWaddr of eth0 - 00:26:55:4F:1F:18 - is still in use by bond0. Set the HWaddr of eth0 to a different address to avoid conflicts.
> Jul 19 11:25:41 bond-test kernel: bonding: bond0: releasing active interface eth0
> Jul 19 11:25:41 bond-test kernel: bonding: bond0: making interface eth1 the new active one.
> Jul 19 11:25:45 bond-test kernel: bonding: bond0: Adding slave eth0.
> Jul 19 11:25:45 bond-test kernel: bnx2: eth0: using MSI
> Jul 19 11:25:45 bond-test kernel: bnx2i [02:00.00]: ISCSI_INIT passed
> Jul 19 11:25:45 bond-test kernel: bonding: bond0: enslaving eth0 as a backup interface with a down link.
> Jul 19 11:25:47 bond-test kernel: bonding: bond0: Removing slave eth1
> Jul 19 11:25:47 bond-test kernel: bonding: bond0: releasing active interface eth1
> Jul 19 11:25:48 bond-test kernel: bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:25:48 bond-test kernel: bonding: bond0: link status up for interface eth0, enabling it in 0 ms.
> Jul 19 11:25:48 bond-test kernel: bonding: bond0: link status definitely up for interface eth0.
> Jul 19 11:25:48 bond-test kernel: bonding: bond0: making interface eth0 the new active one.
> Jul 19 11:25:53 bond-test kernel: bonding: bond0: Adding slave eth1.
> Jul 19 11:25:53 bond-test kernel: bnx2: eth1: using MSI
> Jul 19 11:25:53 bond-test kernel: bnx2i [02:00.01]: ISCSI_INIT passed
> Jul 19 11:25:53 bond-test kernel: bonding: bond0: enslaving eth1 as a backup interface with a down link.
> Jul 19 11:25:55 bond-test kernel: bonding: bond0: Removing slave eth0
> Jul 19 11:25:55 bond-test kernel: bonding: bond0: Warning: the permanent HWaddr of eth0 - 00:26:55:4F:1F:18 - is still in use by bond0. Set the HWaddr of eth0 to a different address to avoid conflicts.
> Jul 19 11:25:55 bond-test kernel: bonding: bond0: releasing active interface eth0
> Jul 19 11:25:56 bond-test kernel: bnx2: eth1 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:25:56 bond-test kernel: bonding: bond0: link status up for interface eth1, enabling it in 0 ms.
> Jul 19 11:25:56 bond-test kernel: bonding: bond0: link status definitely up for interface eth1.
> Jul 19 11:25:56 bond-test kernel: bonding: bond0: making interface eth1 the new active one.
> Jul 19 11:25:59 bond-test kernel: bonding: bond0: Adding slave eth0.
> Jul 19 11:25:59 bond-test kernel: bnx2: eth0: using MSI
> Jul 19 11:25:59 bond-test kernel: bnx2i [02:00.00]: ISCSI_INIT passed
> Jul 19 11:25:59 bond-test kernel: bonding: bond0: enslaving eth0 as a backup interface with a down link.
> Jul 19 11:26:02 bond-test kernel: bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:26:02 bond-test kernel: bonding: bond0: link status up for interface eth0, enabling it in 100 ms.
> Jul 19 11:26:02 bond-test kernel: bonding: bond0: link status definitely up for interface eth0.
> Jul 19 11:26:02 bond-test kernel: bonding: bond0: making interface eth0 the new active one.
> Jul 19 11:26:27 bond-test kernel: bonding: bond0: Removing slave eth1
> Jul 19 11:26:27 bond-test kernel: bonding: bond0: releasing backup interface eth1
> Jul 19 11:26:29 bond-test kernel: bonding: bond0: Adding slave eth1.
> Jul 19 11:26:29 bond-test kernel: bnx2: eth1: using MSI
> Jul 19 11:26:29 bond-test kernel: bnx2i [02:00.01]: ISCSI_INIT passed
> Jul 19 11:26:29 bond-test kernel: bonding: bond0: enslaving eth1 as a backup interface with a down link.
> Jul 19 11:26:32 bond-test kernel: bnx2: eth1 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:26:32 bond-test kernel: bonding: bond0: link status up for interface eth1, enabling it in 100 ms.
> Jul 19 11:26:32 bond-test kernel: bonding: bond0: link status definitely up for interface eth1.
> Jul 19 11:26:33 bond-test kernel: bonding: bond0: Removing slave eth0
> Jul 19 11:26:33 bond-test kernel: bonding: bond0: Warning: the permanent HWaddr of eth0 - 00:26:55:4F:1F:18 - is still in use by bond0. Set the HWaddr of eth0 to a different address to avoid conflicts.
> Jul 19 11:26:33 bond-test kernel: bonding: bond0: releasing active interface eth0
> Jul 19 11:26:33 bond-test kernel: bonding: bond0: making interface eth1 the new active one.
> Jul 19 11:26:36 bond-test kernel: bonding: bond0: Adding slave eth0.
> Jul 19 11:26:36 bond-test kernel: bnx2: eth0: using MSI
> Jul 19 11:26:36 bond-test kernel: bnx2i [02:00.00]: ISCSI_INIT passed
> Jul 19 11:26:36 bond-test kernel: bonding: bond0: enslaving eth0 as a backup interface with a down link.
> Jul 19 11:26:38 bond-test kernel: bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:26:39 bond-test kernel: bonding: bond0: link status up for interface eth0, enabling it in 100 ms.
> Jul 19 11:26:39 bond-test kernel: bonding: bond0: link status definitely up for interface eth0.
> Jul 19 11:26:39 bond-test kernel: bonding: bond0: making interface eth0 the new active one.
> Jul 19 11:27:07 bond-test kernel: bonding: bond0: Removing slave eth1
> Jul 19 11:27:07 bond-test kernel: bonding: bond0: releasing backup interface eth1
> Jul 19 11:27:09 bond-test kernel: bonding: bond0: Adding slave eth1.
> Jul 19 11:27:09 bond-test kernel: bnx2: eth1: using MSI
> Jul 19 11:27:09 bond-test kernel: bnx2i [02:00.01]: ISCSI_INIT passed
> Jul 19 11:27:09 bond-test kernel: bonding: bond0: enslaving eth1 as a backup interface with a down link.
> Jul 19 11:27:12 bond-test kernel: bnx2: eth1 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:27:12 bond-test kernel: bonding: bond0: link status up for interface eth1, enabling it in 100 ms.
> Jul 19 11:27:12 bond-test kernel: bonding: bond0: link status definitely up for interface eth1.
> Jul 19 11:27:12 bond-test kernel: bonding: bond0: Removing slave eth0
> Jul 19 11:27:12 bond-test kernel: bonding: bond0: Warning: the permanent HWaddr of eth0 - 00:26:55:4F:1F:18 - is still in use by bond0. Set the HWaddr of eth0 to a different address to avoid conflicts.
> Jul 19 11:27:12 bond-test kernel: bonding: bond0: releasing active interface eth0
> Jul 19 11:27:12 bond-test kernel: bonding: bond0: making interface eth1 the new active one.
> Jul 19 11:27:15 bond-test kernel: bonding: bond0: Adding slave eth0.
> Jul 19 11:27:15 bond-test kernel: bnx2: eth0: using MSI
> Jul 19 11:27:15 bond-test kernel: bnx2i [02:00.00]: ISCSI_INIT passed
> Jul 19 11:27:15 bond-test kernel: bonding: bond0: enslaving eth0 as a backup interface with a down link.
> Jul 19 11:27:18 bond-test kernel: bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:27:18 bond-test kernel: bonding: bond0: link status up for interface eth0, enabling it in 100 ms.
> Jul 19 11:27:18 bond-test kernel: bonding: bond0: link status definitely up for interface eth0.
> Jul 19 11:27:18 bond-test kernel: bonding: bond0: making interface eth0 the new active one.
> Jul 19 11:27:22 bond-test kernel: bonding: bond0: Removing slave eth1
> Jul 19 11:27:22 bond-test kernel: bonding: bond0: releasing backup interface eth1
> Jul 19 11:27:24 bond-test kernel: bonding: bond0: Adding slave eth1.
> Jul 19 11:27:24 bond-test kernel: bnx2: eth1: using MSI
> Jul 19 11:27:24 bond-test kernel: bnx2i [02:00.01]: ISCSI_INIT passed
> Jul 19 11:27:24 bond-test kernel: bonding: bond0: enslaving eth1 as a backup interface with a down link.
> Jul 19 11:27:26 bond-test kernel: bnx2: eth1 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:27:26 bond-test kernel: bonding: bond0: link status up for interface eth1, enabling it in 100 ms.
> Jul 19 11:27:26 bond-test kernel: bonding: bond0: link status definitely up for interface eth1.
> Jul 19 11:27:27 bond-test kernel: bonding: bond0: Removing slave eth0
> Jul 19 11:27:27 bond-test kernel: bonding: bond0: Warning: the permanent HWaddr of eth0 - 00:26:55:4F:1F:18 - is still in use by bond0. Set the HWaddr of eth0 to a different address to avoid conflicts.
> Jul 19 11:27:27 bond-test kernel: bonding: bond0: releasing active interface eth0
> Jul 19 11:27:27 bond-test kernel: bonding: bond0: making interface eth1 the new active one.
> Jul 19 11:27:30 bond-test kernel: bonding: bond0: Adding slave eth0.
> Jul 19 11:27:30 bond-test kernel: bnx2: eth0: using MSI
> Jul 19 11:27:30 bond-test kernel: bnx2i [02:00.00]: ISCSI_INIT passed
> Jul 19 11:27:30 bond-test kernel: bonding: bond0: enslaving eth0 as a backup interface with a down link.
> Jul 19 11:27:33 bond-test kernel: bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:27:33 bond-test kernel: bonding: bond0: link status up for interface eth0, enabling it in 100 ms.
> Jul 19 11:27:33 bond-test kernel: bonding: bond0: link status definitely up for interface eth0.
> Jul 19 11:27:33 bond-test kernel: bonding: bond0: making interface eth0 the new active one.
> Jul 19 11:27:52 bond-test kernel: bonding: bond0: Removing slave eth1
> Jul 19 11:27:52 bond-test kernel: bonding: bond0: releasing backup interface eth1
> Jul 19 11:27:54 bond-test kernel: bonding: bond0: Adding slave eth1.
> Jul 19 11:27:54 bond-test kernel: bnx2: eth1: using MSI
> Jul 19 11:27:54 bond-test kernel: bnx2i [02:00.01]: ISCSI_INIT passed
> Jul 19 11:27:54 bond-test kernel: bonding: bond0: enslaving eth1 as a backup interface with a down link.
> Jul 19 11:27:56 bond-test kernel: bnx2: eth1 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:27:56 bond-test kernel: bonding: bond0: link status up for interface eth1, enabling it in 100 ms.
> Jul 19 11:27:56 bond-test kernel: bonding: bond0: link status definitely up for interface eth1.
> Jul 19 11:28:05 bond-test kernel: bonding: bond0: Removing slave eth0
> Jul 19 11:28:05 bond-test kernel: bonding: bond0: Warning: the permanent HWaddr of eth0 - 00:26:55:4F:1F:18 - is still in use by bond0. Set the HWaddr of eth0 to a different address to avoid conflicts.
> Jul 19 11:28:05 bond-test kernel: bonding: bond0: releasing active interface eth0
> Jul 19 11:28:05 bond-test kernel: bonding: bond0: making interface eth1 the new active one.
> Jul 19 11:28:07 bond-test ntpd[7189]: synchronized to 144.145.109.92, stratum 3
> Jul 19 11:28:07 bond-test kernel: bonding: bond0: Adding slave eth0.
> Jul 19 11:28:07 bond-test kernel: bnx2: eth0: using MSI
> Jul 19 11:28:07 bond-test kernel: bnx2i [02:00.00]: ISCSI_INIT passed
> Jul 19 11:28:07 bond-test kernel: bonding: bond0: enslaving eth0 as a backup interface with a down link.
> Jul 19 11:28:11 bond-test kernel: bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:28:11 bond-test kernel: bonding: bond0: link status up for interface eth0, enabling it in 100 ms.
> Jul 19 11:28:11 bond-test kernel: bonding: bond0: link status definitely up for interface eth0.
> Jul 19 11:28:11 bond-test kernel: bonding: bond0: making interface eth0 the new active one.
> Jul 19 11:28:32 bond-test kernel: bonding: bond0: Removing slave eth1
> Jul 19 11:28:32 bond-test kernel: bonding: bond0: releasing backup interface eth1
> Jul 19 11:28:34 bond-test kernel: bonding: bond0: Adding slave eth1.
> Jul 19 11:28:34 bond-test kernel: bnx2: eth1: using MSI
> Jul 19 11:28:34 bond-test kernel: bnx2i [02:00.01]: ISCSI_INIT passed
> Jul 19 11:28:34 bond-test kernel: bonding: bond0: enslaving eth1 as a backup interface with a down link.
> Jul 19 11:28:37 bond-test kernel: bnx2: eth1 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:28:37 bond-test kernel: bonding: bond0: link status up for interface eth1, enabling it in 100 ms.
> Jul 19 11:28:37 bond-test kernel: bonding: bond0: link status definitely up for interface eth1.
> Jul 19 11:28:40 bond-test kernel: bonding: bond0: Removing slave eth0
> Jul 19 11:28:40 bond-test kernel: bonding: bond0: Warning: the permanent HWaddr of eth0 - 00:26:55:4F:1F:18 - is still in use by bond0. Set the HWaddr of eth0 to a different address to avoid conflicts.
> Jul 19 11:28:40 bond-test kernel: bonding: bond0: releasing active interface eth0
> Jul 19 11:28:40 bond-test kernel: bonding: bond0: making interface eth1 the new active one.
> Jul 19 11:28:43 bond-test kernel: bonding: bond0: Adding slave eth0.
> Jul 19 11:28:43 bond-test kernel: bnx2: eth0: using MSI
> Jul 19 11:28:43 bond-test kernel: bnx2i [02:00.00]: ISCSI_INIT passed
> Jul 19 11:28:43 bond-test kernel: bonding: bond0: enslaving eth0 as a backup interface with a down link.
> Jul 19 11:28:45 bond-test kernel: bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:28:45 bond-test kernel: bonding: bond0: link status up for interface eth0, enabling it in 100 ms.
> Jul 19 11:28:45 bond-test kernel: bonding: bond0: link status definitely up for interface eth0.
> Jul 19 11:28:45 bond-test kernel: bonding: bond0: making interface eth0 the new active one.
> Jul 19 11:28:45 bond-test kernel: bonding: bond0: Removing slave eth1
> Jul 19 11:28:45 bond-test kernel: bonding: bond0: releasing backup interface eth1
> Jul 19 11:28:48 bond-test kernel: bonding: bond0: Adding slave eth1.
> Jul 19 11:28:48 bond-test kernel: bnx2: eth1: using MSI
> Jul 19 11:28:48 bond-test kernel: bnx2i [02:00.01]: ISCSI_INIT passed
> Jul 19 11:28:48 bond-test kernel: bonding: bond0: enslaving eth1 as a backup interface with a down link.
> Jul 19 11:28:51 bond-test kernel: bnx2: eth1 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:28:51 bond-test kernel: bonding: bond0: link status up for interface eth1, enabling it in 100 ms.
> Jul 19 11:28:51 bond-test kernel: bonding: bond0: link status definitely up for interface eth1.
> Jul 19 11:28:53 bond-test kernel: bonding: bond0: Removing slave eth0
> Jul 19 11:28:53 bond-test kernel: bonding: bond0: Warning: the permanent HWaddr of eth0 - 00:26:55:4F:1F:18 - is still in use by bond0. Set the HWaddr of eth0 to a different address to avoid conflicts.
> Jul 19 11:28:53 bond-test kernel: bonding: bond0: releasing active interface eth0
> Jul 19 11:28:53 bond-test kernel: bonding: bond0: making interface eth1 the new active one.
> Jul 19 11:28:57 bond-test kernel: bonding: bond0: Adding slave eth0.
> Jul 19 11:28:57 bond-test kernel: bnx2: eth0: using MSI
> Jul 19 11:28:57 bond-test kernel: bnx2i [02:00.00]: ISCSI_INIT passed
> Jul 19 11:28:57 bond-test kernel: bonding: bond0: enslaving eth0 as a backup interface with a down link.
> Jul 19 11:28:59 bond-test kernel: bonding: bond0: Removing slave eth1
> Jul 19 11:28:59 bond-test kernel: bonding: bond0: releasing active interface eth1
> Jul 19 11:29:00 bond-test kernel: bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:29:00 bond-test kernel: bonding: bond0: link status up for interface eth0, enabling it in 0 ms.
> Jul 19 11:29:00 bond-test kernel: bonding: bond0: link status definitely up for interface eth0.
> Jul 19 11:29:00 bond-test kernel: bonding: bond0: making interface eth0 the new active one.
> Jul 19 11:29:13 bond-test kernel: bonding: bond0: Adding slave eth1.
> Jul 19 11:29:13 bond-test kernel: bnx2: eth1: using MSI
> Jul 19 11:29:13 bond-test kernel: bnx2i [02:00.01]: ISCSI_INIT passed
> Jul 19 11:29:13 bond-test kernel: bonding: bond0: enslaving eth1 as a backup interface with a down link.
> Jul 19 11:29:15 bond-test kernel: bonding: bond0: Removing slave eth0
> Jul 19 11:29:15 bond-test kernel: bonding: bond0: Warning: the permanent HWaddr of eth0 - 00:26:55:4F:1F:18 - is still in use by bond0. Set the HWaddr of eth0 to a different address to avoid conflicts.
> Jul 19 11:29:15 bond-test kernel: bonding: bond0: releasing active interface eth0
> Jul 19 11:29:15 bond-test kernel: bnx2: eth1 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:29:16 bond-test kernel: bonding: bond0: link status up for interface eth1, enabling it in 0 ms.
> Jul 19 11:29:16 bond-test kernel: bonding: bond0: link status definitely up for interface eth1.
> Jul 19 11:29:16 bond-test kernel: bonding: bond0: making interface eth1 the new active one.
> Jul 19 11:29:20 bond-test kernel: bonding: bond0: Adding slave eth0.
> Jul 19 11:29:20 bond-test kernel: bnx2: eth0: using MSI
> Jul 19 11:29:20 bond-test kernel: bnx2i [02:00.00]: ISCSI_INIT passed
> Jul 19 11:29:20 bond-test kernel: bonding: bond0: enslaving eth0 as a backup interface with a down link.
> Jul 19 11:29:22 bond-test kernel: bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
> Jul 19 11:29:22 bond-test kernel: bonding: bond0: link status up for interface eth0, enabling it in 100 ms.
> Jul 19 11:29:22 bond-test kernel: bonding: bond0: link status definitely up for interface eth0.
> 
> 
> 
> Thanks,
> Joe

-- 
Joe Jin | Team Leader, Software Development | +8610.8278.6295
ORACLE | Linux and Virtualization
Incubator Building 2-A ZPark | Beijing China, 100094


