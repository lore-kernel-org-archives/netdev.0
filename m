From: "Singh, Krishneil K" <krishneil.k.singh@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH v8 3/3] ixgbe,	ixgbevf: Add new mbox
 API xcast mode
Date: Tue, 13 Oct 2015 16:12:26 +0000
Message-ID: <EF50CC0C76A53A44BAD798C58E0A157E271E74C6@ORSMSX103.amr.corp.intel.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05F28E98@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43604 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932587AbbJMQM3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 12:12:29 -0400
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05F28E98@BPXM14GP.gisp.nec.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Hiroshi Shimamoto
Sent: Thursday, August 27, 2015 11:59 PM
To: Or Gerlitz <gerlitz.or@gmail.com>; Alexander Duyck <alexander.duyck@gmail.com>; Skidmore, Donald C <donald.c.skidmore@intel.com>; Rose, Gregory V <gregory.v.rose@intel.com>; Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; intel-wired-lan@lists.osuosl.org; nhorman@redhat.com; jogreene@redhat.com; Linux Netdev List <netdev@vger.kernel.org>; Choi, Sy Jong <sy.jong.choi@intel.com>; Rony Efraim <ronye@mellanox.com>; Edward Cree <ecree@solarflare.com>; David Miller <davem@davemloft.net>; sassmann@redhat.com
Subject: [Intel-wired-lan] [PATCH v8 3/3] ixgbe, ixgbevf: Add new mbox API xcast mode

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

The limitation of the number of multicast address for VF is not enough for the large scale server with SR-IOV feature. IPv6 requires the multicast MAC address for each IP address to handle the Neighbor Solicitation message. We couldn't assign over 30 IPv6 addresses to a single VF.

This patch introduces the new mailbox API, IXGBE_VF_UPDATE_XCAST_MODE, to update multicast mode of VF. This adds 3 modes;
  - NONE     only L2 exact match addresses or Flow Director enabled
  - MULTI    BAM and ROMPE set
  - ALLMULTI BAM, ROMPE and MPE set

If a guest VF user wants over 30 MAC multicast addresses, set IFF_ALLMULTI to request PF to update xcast mode to enable VF multicast promiscuous mode.

On the other hand, enabling VF multicast promiscuous mode may affect security and performance in the network of the NIC. Only trusted VF can enable multicast promiscuous mode. The behavior of untrusted VF is the same as previous version.

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
---
 
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
