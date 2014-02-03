From: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Subject: linux-3.14-rc1 & PACKET_QDISC_BYPASS : slow_path warning
Date: Mon, 3 Feb 2014 23:47:51 +0100
Message-ID: <52F01C97.20001@fokus.fraunhofer.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------000702020208010209000909"
Cc: <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-relay08-dus.antispameurope.com ([94.100.134.208]:35212 "EHLO
	mx-relay08-dus.antispameurope.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752394AbaBCWyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 17:54:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------000702020208010209000909
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

Hi Daniel,

we are developing a wired/wireless MPLS switch. Currently the data plane 
runs in user space using PF_PACKET sockets via RX_RING/TX_RING.

We had hoped to test the PACKET_QDISC_BYPASS option since this seems to 
be the proper optimization for our purposes.

Unfortunately, we're seeing a 'slow path' warning for every packet that 
is being sent out. With PACKET_QDISC_BYPASS disabled, no warnings are 
dumped. Hardware is an older AMD Geode LX embedded board (ALiX).

BTW, this happens while sending via a wireless (802.11) adhoc interface. 
Hence, it might be an interaction with the ieee80211 sub system.

Please, let me know if you need any further information.

Cheers,

Mathias

-- 
Dr. Mathias Kretschmer, Head of Competence Center
Fraunhofer FOKUS Network Research
A Schloss Birlinghoven, 53754 Sankt Augustin, Germany
T +49-2241-14-3466, F +49-2241-14-1050
E mathias.kretschmer@fokus.fraunhofer.de
W http://www.fokus.fraunhofer.de/en/net

--------------000702020208010209000909
Content-Type: text/plain; charset="UTF-8"; name="slow-path-3.14.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="slow-path-3.14.txt"

[ 3246.953225] ------------[ cut here ]------------
[ 3246.953225] WARNING: CPU: 0 PID: 778 at drivers/net/wireless/ath/ath9k/xmit.c:2195 ath_tx_start+0x245/0x24d()
[ 3246.953225] Modules linked in: lm90 gpio_keys_polled scx200_acb
[ 3246.953225] CPU: 0 PID: 778 Comm: wiback Tainted: G        W    3.14.0-rc1.geode #1
[ 3246.953225]  c13bec9a c10207ed c14f4de0 00000000 0000030a c151cab0 00000893 c121071e
[ 3246.953225]  c121071e 00000893 cf4ba180 cf791b14 c01d8c20 c102081c 00000009 00000000
[ 3246.953225]  c121071e cec3c358 cf7c8c2c 00000200 c01d9eb0 00000000 c01d94dc 00000000
[ 3246.953225] Call Trace:
[ 3246.953225]  [<c13bec9a>] ? dump_stack+0xa/0x13
[ 3246.953225]  [<c10207ed>] ? warn_slowpath_common+0x7a/0x8e
[ 3246.953225]  [<c121071e>] ? ath_tx_start+0x245/0x24d
[ 3246.953225]  [<c121071e>] ? ath_tx_start+0x245/0x24d
[ 3246.953225]  [<c102081c>] ? warn_slowpath_null+0x1b/0x1f
[ 3246.953225]  [<c121071e>] ? ath_tx_start+0x245/0x24d
[ 3246.953225]  [<c120a43f>] ? ath9k_tx+0x7f/0x162
[ 3246.953225]  [<c13a14cd>] ? __ieee80211_tx+0xcf/0x288
[ 3246.953225]  [<c13a314b>] ? ieee80211_tx+0xa0/0xc0
[ 3246.953225]  [<c13a395c>] ? ieee80211_xmit+0x81/0x99
[ 3246.953225]  [<c13a4454>] ? ieee80211_subif_start_xmit+0x7d0/0x934
[ 3246.953225]  [<c134e8da>] ? packet_direct_xmit+0x6a/0xee
[ 3246.953225]  [<c13506bb>] ? packet_sendmsg+0x4eb/0xd58
[ 3246.953225]  [<c12ae6fb>] ? sock_sendmsg+0x4f/0x6f
[ 3246.953225]  [<c12afe68>] ? SYSC_sendto+0xc8/0xe9
[ 3246.953225]  [<c103a85f>] ? sched_clock_local.constprop.7+0x39/0x152
[ 3246.953225]  [<c12b0c63>] ? SYSC_socketcall+0x3c8/0x8f7
[ 3246.953225]  [<c13c0d68>] ? __schedule+0x164/0x3c0
[ 3246.953225]  [<c103a85f>] ? sched_clock_local.constprop.7+0x39/0x152
[ 3246.953225]  [<c1045fef>] ? ktime_get+0x4c/0xd4
[ 3246.953225]  [<c10ae7b5>] ? ep_send_events_proc+0x69/0x105
[ 3246.953225]  [<c10ae74c>] ? ep_read_events_proc+0x78/0x78
[ 3246.953225]  [<c10aee5f>] ? ep_scan_ready_list.isra.27+0x122/0x13d
[ 3246.953225]  [<c10ae74c>] ? ep_read_events_proc+0x78/0x78
[ 3246.953225]  [<c10b0765>] ? timerfd_read+0xa6/0x25e
[ 3246.953225]  [<c10aef9d>] ? ep_poll+0x109/0x234
[ 3246.953225]  [<c12b123f>] ? SyS_socketcall+0xd/0xe
[ 3246.953225]  [<c13c28ed>] ? syscall_call+0x7/0xb
[ 3246.953225] ---[ end trace c930b576e9270049 ]---


--------------000702020208010209000909--
