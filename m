From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: WARNING: at include/net/sock.h:417 udp_lib_unhash
Date: Wed, 1 Jul 2009 12:08:17 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365F8AB77D05@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:64809 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791AbZGASIP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 14:08:15 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see the following trace during netperf stress mixed UDP/TCP IPv4/6 traffic. This is on recent pulls from net-2.6 and net-next.

[45197.989163] ------------[ cut here ]------------
[45197.994309] WARNING: at include/net/sock.h:417 udp_lib_unhash+0x81/0xab()
[45197.994311] Hardware name: X7DA8
[45197.994314] Modules linked in: e1000 [last unloaded: e1000]
[45197.994326] Pid: 7110, comm: netserver Tainted: G        W  2.6.31-rc1-net-next-e1000-06250902 #8
[45197.994331] Call Trace:
[45197.994336]  [<ffffffff8135e0dc>] ? udp_lib_unhash+0x81/0xab
[45197.994344]  [<ffffffff8103cac9>] warn_slowpath_common+0x77/0x8f
[45197.994349]  [<ffffffff8103caf0>] warn_slowpath_null+0xf/0x11
[45197.994352]  [<ffffffff8135e0dc>] udp_lib_unhash+0x81/0xab
[45197.994357]  [<ffffffff81301acb>] sk_common_release+0x2f/0xb4
[45197.994364]  [<ffffffff813a0256>] udp_lib_close+0x9/0xb
[45197.994369]  [<ffffffff81364259>] inet_release+0x58/0x5f
[45197.994374]  [<ffffffff8138c8bd>] inet6_release+0x30/0x35
[45197.994383]  [<ffffffff812ff273>] sock_release+0x1a/0x6c
[45197.994386]  [<ffffffff812ff763>] sock_close+0x22/0x26
[45197.994392]  [<ffffffff810c69a0>] __fput+0xf0/0x18c
[45197.994395]  [<ffffffff810c6d00>] fput+0x15/0x19
[45197.994399]  [<ffffffff810c3c3e>] filp_close+0x5c/0x67
[45197.994404]  [<ffffffff810c3cc4>] sys_close+0x7b/0xb6
[45197.994412]  [<ffffffff8100baeb>] system_call_fastpath+0x16/0x1b
[45197.994418] ---[ end trace 5acab6fc0afdaaa3 ]---

Emil