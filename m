From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: packetloss, on e1000e worse than r8169?
Date: Mon, 16 Jun 2008 13:37:06 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290540BE25@orsmsx414.amr.corp.intel.com>
References: <20080616193501.M64730@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Linux NICS" <linuxnics@mailbox.intel.com>
To: "Denys Fedoryshchenko" <denys@visp.net.lb>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5860 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751556AbYFPUhI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 16:37:08 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080616193501.M64730@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>MegaRouter-KARAM /sys # ethtool -S eth1
>NIC statistics:
>     rx_packets: 109977509
>     tx_packets: 109887692
>     rx_bytes: 57656749138
>     tx_bytes: 57536071746
>     rx_broadcast: 6497
>     tx_broadcast: 92
>     rx_multicast: 48995
>     tx_multicast: 1960
>     rx_errors: 0
>     tx_errors: 0
>     tx_dropped: 0
>     multicast: 48995
>     collisions: 0
>     rx_length_errors: 0
>     rx_over_errors: 0
>     rx_crc_errors: 0
>     rx_frame_errors: 0
>     rx_no_buffer_count: 1796
>     rx_missed_errors: 2182679

This is an indication here that your host isn't processing your Rx fast
enough, and your Rx ring is out of descriptors.  Hence, your hardware is
needing to drop the packet.  What's disturbing is that you actually do
have flow control packets being processed, so the NIC is trying to help
the host.

>     tx_aborted_errors: 0
>     tx_carrier_errors: 0
>     tx_fifo_errors: 0
>     tx_heartbeat_errors: 0
>     tx_window_errors: 0
>     tx_abort_late_coll: 0
>     tx_deferred_ok: 55617
>     tx_single_coll_ok: 0
>     tx_multi_coll_ok: 0
>     tx_timeout_count: 0
>     tx_restart_queue: 1626
>     rx_long_length_errors: 0
>     rx_short_length_errors: 0
>     rx_align_errors: 0
>     tx_tcp_seg_good: 0
>     tx_tcp_seg_failed: 0
>     rx_flow_control_xon: 55461
>     rx_flow_control_xoff: 57329
>     tx_flow_control_xon: 39114
>     tx_flow_control_xoff: 48341
>     rx_long_byte_count: 57656749138
>     rx_csum_offload_good: 104097306
>     rx_csum_offload_errors: 2209

This is also a bit disturbing, that Rx CSUM offload is running into
issues.  I think though this is due to the rx_no_buffer_count.

I see in a followup email you tried increasing your ring size to 4096
descriptors.  I'd suggest trying 512 descriptors; something slow,
instead of going for 4096 out of the gate.  However, if your host can't
keep up with 256 descriptors, I think you're just going to prolong your
problem by increasing your descriptor ring size.  But I don't know what
the profile of your traffic is, so perhaps bumping up the descriptor
ring size to 512 or even 1024 descriptors might help.

Cheers,
-PJ Waskiewicz
<peter.p.waskiewicz.jr@intel.com>
