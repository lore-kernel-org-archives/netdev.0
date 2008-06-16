From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: RE: packetloss, on e1000e worse than r8169?
Date: Mon, 16 Jun 2008 23:42:42 +0300
Message-ID: <20080616203832.M12498@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <D5C1322C3E673F459512FB59E0DDC3290540BE25@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:50540 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739AbYFPUnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 16:43:02 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290540BE25@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jun 2008 13:37:06 -0700, Waskiewicz Jr, Peter P wrote
> >MegaRouter-KARAM /sys # ethtool -S eth1
> >NIC statistics:
> >     rx_packets: 109977509
> >     tx_packets: 109887692
> >     rx_bytes: 57656749138
> >     tx_bytes: 57536071746
> >     rx_broadcast: 6497
> >     tx_broadcast: 92
> >     rx_multicast: 48995
> >     tx_multicast: 1960
> >     rx_errors: 0
> >     tx_errors: 0
> >     tx_dropped: 0
> >     multicast: 48995
> >     collisions: 0
> >     rx_length_errors: 0
> >     rx_over_errors: 0
> >     rx_crc_errors: 0
> >     rx_frame_errors: 0
> >     rx_no_buffer_count: 1796
> >     rx_missed_errors: 2182679
> 
> This is an indication here that your host isn't processing your Rx fast
> enough, and your Rx ring is out of descriptors.  Hence, your 
> hardware is needing to drop the packet.  What's disturbing is that 
> you actually do have flow control packets being processed, so the 
> NIC is trying to help the host.
> 
> >     tx_aborted_errors: 0
> >     tx_carrier_errors: 0
> >     tx_fifo_errors: 0
> >     tx_heartbeat_errors: 0
> >     tx_window_errors: 0
> >     tx_abort_late_coll: 0
> >     tx_deferred_ok: 55617
> >     tx_single_coll_ok: 0
> >     tx_multi_coll_ok: 0
> >     tx_timeout_count: 0
> >     tx_restart_queue: 1626
> >     rx_long_length_errors: 0
> >     rx_short_length_errors: 0
> >     rx_align_errors: 0
> >     tx_tcp_seg_good: 0
> >     tx_tcp_seg_failed: 0
> >     rx_flow_control_xon: 55461
> >     rx_flow_control_xoff: 57329
> >     tx_flow_control_xon: 39114
> >     tx_flow_control_xoff: 48341
> >     rx_long_byte_count: 57656749138
> >     rx_csum_offload_good: 104097306
> >     rx_csum_offload_errors: 2209
> 
> This is also a bit disturbing, that Rx CSUM offload is running into
> issues.  I think though this is due to the rx_no_buffer_count.
> 
> I see in a followup email you tried increasing your ring size to 4096
> descriptors.  I'd suggest trying 512 descriptors; something slow,
> instead of going for 4096 out of the gate.  However, if your host can't
> keep up with 256 descriptors, I think you're just going to prolong your
> problem by increasing your descriptor ring size.  But I don't know what
> the profile of your traffic is, so perhaps bumping up the descriptor
> ring size to 512 or even 1024 descriptors might help.
> 

If i am not wrong when situation is related to ring, i will have large amount
of errors in rx_no_buffer_count. I tried now 512 and 1024, it doesn't change
anything at all.

MegaRouter-KARAM ~ # ethtool -g eth1
Ring parameters for eth1:
Pre-set maximums:
RX:             4096
RX Mini:        0
RX Jumbo:       0
TX:             4096
Current hardware settings:
RX:             1024
RX Mini:        0
RX Jumbo:       0
TX:             256


MegaRouter-KARAM ~ # ifconfig eth1; sleep 10;ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
          inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:105760686 errors:0 dropped:1728264 overruns:0 frame:0
          TX packets:105667743 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:4291052222 (3.9 GiB)  TX bytes:4081974720 (3.8 GiB)
          Memory:90300000-90320000

eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
          inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:106541093 errors:0 dropped:1744393 overruns:0 frame:0
          TX packets:106447803 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:413277601 (394.1 MiB)  TX bytes:202824806 (193.4 MiB)
          Memory:90300000-90320000


rx_no_buffer_count is not a big deal, i had this issue on Sun Fire (e1000 over
PCI-X 66 Mhz), and increasing ring solved the problem. But this case seems
different. My headache now is rx_missed_errors. It can be bus bandwidth hog
also, as i read in maillists, but it's supposed to be x1 PCI-Express with 2.5
GB/s throughput!

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

