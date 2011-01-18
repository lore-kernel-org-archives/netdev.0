From: "Mills, Tony" <tony.mills@jagex.com>
Subject: bnx2 cards intermittantly going offline
Date: Tue, 18 Jan 2011 10:54:28 +0000
Message-ID: <6DD3782C33561D44B47071B09946026405F63853AB@exchange1>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.jagex.com ([212.44.19.211]:5878 "EHLO mx2.jagex.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752052Ab1ARKyd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 05:54:33 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

I was running Debian lenny 64bit with a 2.6.24 kernel which seemed to have a rather old version of the bnx2 driver, I have been getting reports that there have been issues with connectivity, this seems to happen randomly across many different servers in different data centres. 

Further investigation showed that the interfaces become completely unresponsive for periods of time, whereby machines are unable to ping the host with the problem and the server  with the problem is unable to ping out, our tcp application which is time critical will kick off connections. 

The network cards are Broadcom NetXtreme II BCM5708 Gigabit Ethernet cards on Dell 2950's plugged into  Cisco 3750E's. 

Reading various posts indicated that I might be experiencing a problem that may have already been solved so attempted to build  the drivers from the Broadcom website into the 2.4.24 kernel without success, eventually compiling against a 2.3.32 kernel worked great. 

I have installed this on 4 machines in different data centres and followed some of the other posts I have found, in an attempt to fix the issues, however none of the things i have tried appear to be affective :-

1.	 Was seeing rx_fw_discards so upped rx ring buffer to both 1020 and 4080, this stopped the rx_fw_discards but not the "unresponsiveness". 
2.	Have enabled flow control on one of the machines, this still has the unresponsive behaviour and the port on the switch shows 0 pause frames received. 
3.	Upgraded the kernel and driver to latest available. 

Last night i setup a machine to monitor overnight and at 3:52 this morning it became unresponsive. 

The switch was setup to "flowcontrol desired", and the machine had the following settings:-

ethtool -g eth0
Ring parameters for eth0:
Pre-set maximums:
RX:                         4080
RX Mini:               0
RX Jumbo:           16320
TX:                          255
Current hardware settings:
RX:                         4080
RX Mini:               0
RX Jumbo:           0
TX:                          255

ethtool -a eth0
Pause parameters for eth0:
Autonegotiate: on
RX:                         on
TX:                          on

The output from ethtool -S eth0

NIC statistics:
     rx_bytes: 65832403312
     rx_error_bytes: 0
     tx_bytes: 141615699363
     tx_error_bytes: 0
     rx_ucast_packets: 565468011
     rx_mcast_packets: 3
     rx_bcast_packets: 193008
     tx_ucast_packets: 768277404
     tx_mcast_packets: 8
     tx_bcast_packets: 657
     tx_mac_errors: 0
     tx_carrier_errors: 0
     rx_crc_errors: 0
     rx_align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     tx_deferred: 0
     tx_excess_collisions: 0
     tx_late_collisions: 0
     tx_total_collisions: 0
     rx_fragments: 0
     rx_jabbers: 0
     rx_undersize_packets: 0
     rx_oversize_packets: 0
     rx_64_byte_packets: 398958533
     rx_65_to_127_byte_packets: 125222178
     rx_128_to_255_byte_packets: 16962519
     rx_256_to_511_byte_packets: 6100929
     rx_512_to_1023_byte_packets: 2314593
     rx_1024_to_1522_byte_packets: 16102270
     rx_1523_to_9022_byte_packets: 0
     tx_64_byte_packets: 331974057
     tx_65_to_127_byte_packets: 239480821
     tx_128_to_255_byte_packets: 78102231
     tx_256_to_511_byte_packets: 33163946
     tx_512_to_1023_byte_packets: 57321357
     tx_1024_to_1522_byte_packets: 28235657
     tx_1523_to_9022_byte_packets: 0
     rx_xon_frames: 0
     rx_xoff_frames: 0
     tx_xon_frames: 0
     tx_xoff_frames: 0
     rx_mac_ctrl_frames: 0
     rx_filtered_packets: 43417
     rx_ftq_discards: 0
     rx_discards: 0
     rx_fw_discards: 0

The switch port showed no pause frames

show interfaces gigabitEthernet X/X/X flowcontrol 
Port       Send FlowControl  Receive FlowControl  RxPause TxPause
           admin    oper     admin    oper                       
---------  -------- -------- -------- --------    ------- -------
GiX/X/X   Unsupp.  Unsupp.  desired  on          0       0   

(The switch is unable to send flow control packets but can receive).

Would someone be able to point me at anything else that may help identify/fix the issue. 

Best Regards

Tony Mills
-- 
IMPORTANT NOTICE

The sender does not guarantee that this message, including any attachment, is secure
or virus free. Also, it is confidential and may be privileged or otherwise protected
from disclosure. If you are not the intended recipient, do not disclose or copy it
or its contents. Please telephone or email the sender and delete the message
entirely from your system.
Jagex Limited is a company registered in England & Wales with company number
03982706 and a registered office at St John's Innovation Centre, Cowley Road, 
Cambridge, CB4 0WS, UK.
