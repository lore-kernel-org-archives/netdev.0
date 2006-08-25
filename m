From: Joy Latten <latten@austin.ibm.com>
Subject: IPSec kernel oops on ppc64
Date: Fri, 25 Aug 2006 17:10:59 -0500
Message-ID: <200608252210.k7PMAxpO025638@faith.austin.ibm.com>
Cc: gcwilson@us.ibm.com, jmorris@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:62408 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1422916AbWHYWVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 18:21:54 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7PMLrlu024477
	for <netdev@vger.kernel.org>; Fri, 25 Aug 2006 18:21:53 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7PMLrGX257296
	for <netdev@vger.kernel.org>; Fri, 25 Aug 2006 18:21:53 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7PMLqaJ007742
	for <netdev@vger.kernel.org>; Fri, 25 Aug 2006 18:21:52 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I installed 2.6.17 + patch-2.6.18-rc4 + 2.6.18-rc4-mm2
onto two pSeries power 5 (ppc64 lpars) machines. I configured
IPSec using the configuration listed below. 

A ping from one machine to the other, hangs. 
No packets leave the machine issuing the ping.
When I tried sftp, I received following oops.

Has anyone else had problems with IPSec on pSeries?

[root@joy-hv4 jml]# sftp hvracer1
Connecting to hvracer1...
kernel BUG in skb_to_sgvec at net/xfrm/xfrm_algo.c:620!
cpu 0x0: Vector: 700 (Program Check) at [c0000000466eb240]
    pc: c00000000035f2f4: .skb_to_sgvec+0x288/0x2ec
    lr: d0000000009605e0: .esp_output+0x340/0x494 [esp4]
    sp: c0000000466eb4c0
   msr: 8000000000029032
  current = 0xc000000045a69910
  paca    = 0xc000000000484400
    pid   = 2213, comm = ssh
kernel BUG in skb_to_sgvec at net/xfrm/xfrm_algo.c:620!
enter ? for help
0:mon> t
[c0000000466eb590] d0000000009605e0 .esp_output+0x340/0x494 [esp4]
[c0000000466eb680] c000000000357bd4 .xfrm4_output_finish2+0x2b8/0x3d0
[c0000000466eb720] c000000000357ea0 .xfrm4_output+0x74/0x88
[c0000000466eb7a0] c00000000031b188 .ip_queue_xmit+0x4a8/0x540
[c0000000466eb8a0] c00000000032e9b8 .tcp_transmit_skb+0x820/0x890
[c0000000466eb960] c000000000331b74 .tcp_connect+0x308/0x3b0
[c0000000466eba00] c0000000003361d0 .tcp_v4_connect+0x52c/0x6c0
[c0000000466ebb80] c000000000344664 .inet_stream_connect+0x10c/0x358
[c0000000466ebc60] c0000000002dba14 .sys_connect+0xd8/0x120
[c0000000466ebd90] c0000000002fe420 .compat_sys_socketcall+0xdc/0x214
[c0000000466ebe30] c00000000000871c syscall_exit+0x0/0x40
--- Exception: c00 (System Call) at 0000000007a9f8fc
SP (fc63f230) is in userspace


------------------------------------------------------------------------
Configured IPSec as follows:

add x.x.x.55 x.x.x.206 esp 35590
-m transport
-E 3des-cbc "06183223c23a21e8b36c566b"
-A hmac-md5 "TAHITEST89ABCDEF";

add x.x.x.206 x.x.x.55 esp 12360
-m transport
-E 3des-cbc "06183223c23a21e8b36c566b"
-A hmac-md5 "TAHITEST89ABCDEF";

spdadd x.x.x.55 x.x.x.206 any -P in ipsec
        esp/transport//require;

spdadd x.x.x.206 x.x.x.55 any -P out ipsec
        esp/transport//require;

Same config on both machines, except for  spdadd entry. The "in" and "out"
are swapped on the other machine.


Regards,
Joy Latten
