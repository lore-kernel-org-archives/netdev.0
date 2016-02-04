From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: bonding reports interface up with 0 Mbps
Date: Thu, 04 Feb 2016 12:29:33 -0800
Message-ID: <22896.1454617773@famine>
References: <87618083B2453E4A8714035B62D6799250524233@FMSMSX105.amr.corp.intel.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	zhuyj <zyjzyj2000@gmail.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:54162 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbcBDU3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 15:29:38 -0500
In-reply-to: <87618083B2453E4A8714035B62D6799250524233@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tantilov, Emil S <emil.s.tantilov@intel.com> wrote:

>We are seeing an occasional issue where the bonding driver may report interface up with 0 Mbps:
>bond0: link status definitely up for interface eth0, 0 Mbps full duplex
>
>So far in all the failed traces I have collected this happens on NETDEV_CHANGELOWERSTATE event:
>
><...>-20533 [000] .... 81811.041241: ixgbe_service_task: eth1: NIC Link is Up 10 Gbps, Flow Control: RX/TX
><...>-20533 [000] .... 81811.041257: ixgbe_check_vf_rate_limit <-ixgbe_service_task
><...>-20533 [000] .... 81811.041272: ixgbe_ping_all_vfs <-ixgbe_service_task
>kworker/u48:0-7503  [010] .... 81811.041345: ixgbe_get_stats64 <-dev_get_stats
>kworker/u48:0-7503  [010] .... 81811.041393: bond_netdev_event: eth1: event: 1b
>kworker/u48:0-7503  [010] .... 81811.041394: bond_netdev_event: eth1: IFF_SLAVE
>kworker/u48:0-7503  [010] .... 81811.041395: bond_netdev_event: eth1: slave->speed = ffffffff
><...>-20533 [000] .... 81811.041407: ixgbe_ptp_overflow_check <-ixgbe_service_task
>kworker/u48:0-7503  [010] .... 81811.041407: bond_mii_monitor: bond0: link status definitely up for interface eth1, 0 Mbps full duplex

	Thinking about the trace again... Emil: what happens in the
trace before this?  Is there ever a call to the ixgbe_get_settings?
Does a NETDEV_UP or NETDEV_CHANGE event ever hit the bond_netdev_event
function?

	Could you describe your test that reproduces this?  I'd like to
see if I can set it up locally.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
