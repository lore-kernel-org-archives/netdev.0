From: Jason Lunz <lunz@reflexsecurity.com>
Subject: Re: e100-3.0.0_dev8 "Minneapolis Moline" release
Date: Wed, 18 Jun 2003 15:54:32 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnbf12pr.kck.lunz@stoli.localnet>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D977@orsmsx402.jf.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

scott.feldman@intel.com said:
> Your help in testing would be greatly appreciated.  There are many 8255x
> devices supported by e100, so hopefully we'll get good coverage from the
> community.

It's running on my workstation with no problems. passes the "ping -qf"
load test. lspci says I have:

00:0b.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 08)
        Subsystem: Intel Corp. EtherExpress PRO/100+ Management Adapter
        Flags: bus master, medium devsel, latency 32, IRQ 11
        Memory at d8100000 (32-bit, non-prefetchable) [size=4K]
        I/O ports at e800 [size=64]
        Memory at d8000000 (32-bit, non-prefetchable) [size=1M]
        Expansion ROM at <unassigned> [disabled] [size=1M]
        Capabilities: [dc] Power Management version 2

ethtool output seems normal, but what's with the rx-mini and rx-jumbo
max settings in the -g output?

[stoli](0) # ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Half
        Port: MII
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Current message level: 0x00000007 (7)
        Link detected: yes

[stoli](0) # ethtool -a eth0
Pause parameters for eth0:
Cannot get device pause settings: Operation not supported

[stoli](76) # ethtool -c eth0
Coalesce parameters for eth0:
Cannot get device coalesce settings: Operation not supported

[stoli](82) # ethtool -g eth0
Ring parameters for eth0:
Pre-set maximums:
RX:             256
RX Mini:        134512692
RX Jumbo:       134512692
TX:             256
Current hardware settings:
RX:             64
RX Mini:        5
RX Jumbo:       4
TX:             64

[stoli](0) # ethtool -i eth0
driver: e100
version: 3.0.0_dev8
firmware-version: N/A
bus-info: 00:0b.0

[stoli](0) # ethtool -d eth0
SCB Status and Command Word
-------------
SCB Status Word (Lower Word)             0x0050
      RU Status:               Ready
      CU Status:               Suspended
      ---- Interrupts Pending ----
      Flow Control Pause:                no
      Early Receive:                     no
      Software Generated Interrupt:      no
      MDI Done:                          no
      RU Not In Ready State:             no
      CU Not in Active State:            no
      RU Received Frame:                 no
      CU Completed Command:              no
SCB Command Word (Upper Word)            0x0000
      RU Command:              No Command
      CU Command:              No Command
      Software Generated Interrupt:      no
      ---- Interrupts Masked ----
      ALL Interrupts:                    no
      Flow Control Pause:                no
      Early Receive:                     no
      RU Not In Ready State:             no
      CU Not in Active State:            no
      RU Received Frame:                 no
      CU Completed Command:              no

[stoli](0) # ethtool -e eth0
Offset          Values
------          ------
0x0000          00 02 b3 11 b9 e0 03 02 00 00 01 02 01 47 00 00
0x0010          13 72 10 83 a2 40 0c 00 86 80 00 00 00 00 00 00
0x0020          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0030          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0040          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0050          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0060          a8 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0070          00 00 00 00 00 00 00 00 00 00 00 00 00 00 4a c3

[stoli](0) # ethtool -k eth0
RX/TX checksumming parameters for eth0:
Cannot get device rx csum settings: Operation not supported
Cannot get device tx csum settings: Operation not supported
Cannot get device scatter-gather settings: Operation not supported
no checksumming/SG info available

[stoli](83) # ethtool -p eth0

[stoli](130) # ethtool -r eth0

[stoli](0) # ethtool -S eth0
NIC statistics:
     rx_packets: 1410143
     tx_packets: 1410029
     rx_bytes: 138271433
     tx_bytes: 138179379
     rx_errors: 41
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     multicast: 0
     collisions: 136914
     rx_length_errors: 41
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0

[stoli](0) # ethtool -t  eth0 online
The test result is PASS
The test extra info:
Link test     (on/offline)       0
Eeprom test   (on/offline)       0
Self test        (offline)       0
Mac loopback     (offline)       0
Phy loopback     (offline)       0

[stoli](0) # ethtool -t  eth0 offline
The test result is PASS
The test extra info:
Link test     (on/offline)       0
Eeprom test   (on/offline)       0
Self test        (offline)       0
Mac loopback     (offline)       0
Phy loopback     (offline)       0

-- 
Jason Lunz			Reflex Security
lunz@reflexsecurity.com		http://www.reflexsecurity.com/
