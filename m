From: P@draigBrady.com
Subject: e1000 jumbo problems
Date: Tue, 22 Jun 2004 19:04:01 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D87491.9040709@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Summary, machine locks up when receiving jumbo frames.

machine =3D 2 P4 CPUs with hyperthreading, so 4 logical CPUs, 512MiB RAM
I'm using linux 2.4.20 with e1000-5.2.52 in NAPI mode
(with the fix applied in -k3 to fix NAPI/ifdown crash)
I was also seeing the same problem with 5.2.30.1
I'm also using IRQ affinity:

            CPU0       CPU1       CPU2       CPU3
  24:    7096026          0          0          0   IO-APIC-level
  25:          2          0      61115          0   IO-APIC-level

The problem seems independent of mtu size, and
I've set MTUs of 4000, 9000, 16110 with the same problem.

When sending packets of up to 2K in size on one interface
at a rate of about 5Kpps there is no problem. But once I go
above that packet size I can get the machine to hang up within
a minute or two.
Note the interface is in promiscous mode and hangs whether
the packets are just dropped by the driver or processed
(by a userspace program).
There are no oops at all, the system just freezes
(numlock etc. is dead also).

Note if packets are sent in between 2K and 2.5K
in size, there seems to be driver structure corruption
rather than a system freeze. In this state the
interface bounces every minute or so. Also this is
the ethtool -S output (which changes a little for each run
even though no packets are being received?):

NIC statistics:
      rx_packets: 153018775
      tx_packets: 152565456
      rx_bytes: 1093747991
      tx_bytes: 152565456
      rx_errors: 1067958192
      tx_errors: 305130916
      rx_dropped: 152565456
      tx_dropped: 0
      multicast: 152918771
      collisions: 152565454
      rx_length_errors: 152565456
      rx_over_errors: 0
      rx_crc_errors: 152565460
      rx_frame_errors: 152565454
      rx_fifo_errors: 152565458
      rx_missed_errors: 152565458
      tx_aborted_errors: 152565458
      tx_carrier_errors: 152565454
      tx_fifo_errors: 0
      tx_heartbeat_errors: 0
      tx_window_errors: 152565458
      tx_abort_late_coll: 10106210612946
      tx_deferred_ok: 10110505580240
      tx_single_coll_ok: 10106210612946
      tx_multi_coll_ok: 10106210612946
      rx_long_length_errors: 10106210612946
      rx_short_length_errors: 10110505580240
      rx_align_errors: 10114800547534
      tx_tcp_seg_good: 10114800547534
      tx_tcp_seg_failed: 10114800547534
      rx_flow_control_xon: 10110505580240
      rx_flow_control_xoff: 10110505580240
      tx_flow_control_xon: 10110505580240
      tx_flow_control_xoff: 10110505580240
      rx_csum_offload_good: 0
      rx_csum_offload_errors: 0

I also noticed driver structure corruption exactly like
above when transmitting packets in the 1500 -> 2000 bytes range.

Another related issue, is that the driver uses 4096KiB buffers
for MTUs in the 1500 -> 2000 range which seems a bit silly.
Any particular reason for that?

Also is there a public dev tree available for the e1000 driver?

cheers,
P=C3=A1draig.
