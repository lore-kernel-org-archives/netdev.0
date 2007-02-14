From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: [Bugme-new] [Bug 8009] New: PPPoE+mppe Server fail with Win
 Client
Date: Wed, 14 Feb 2007 10:11:12 -0800
Message-ID: <20070214101112.aec6635d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, giacomo.battiston@gmail.com,
	Matt Domsch <Matt_Domsch@dell.com>,
	James Cameron <james.cameron@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38000 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932419AbXBNSLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Feb 2007 13:11:31 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 14 Feb 2007 02:30:59 -0800
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 8009] New: PPPoE+mppe Server fail with Win Client


http://bugzilla.kernel.org/show_bug.cgi?id=8009

           Summary: PPPoE+mppe Server fail with Win Client
    Kernel Version: linux-2.6.18
            Status: NEW
          Severity: normal
             Owner: jgarzik@pobox.com
         Submitter: giacomo.battiston@gmail.com


Most recent kernel where this bug did *NOT* occur: -
Distribution: Gentoo
Hardware Environment: i386
Software Environment: ppp-2.4.4 + rp-pppoe-3.8

/etc/ppp/options:
name PPPoE-R
noipdefault
ipcp-accept-local
ipcp-accept-remote
debug
lock
auth
local
crtscts
asyncmap 0
mru 1480
mtu 1480
nobsdcomp
nodetach
lcp-echo-interval 30
lcp-echo-failure 4
lcp-max-configure 60
lcp-restart 2
idle 600
noipx
ms-dns 212.216.112.112
ms-dns 192.168.3.39
logfile /var/log/ppp/pppoe.log
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
lcp-echo-interval 10
lcp-echo-failure 2
require-mppe
mppe-stateful
plugin rp-pppoe.so
plugin radius.so

Problem Description:
When i try to connect with linux i have no problem (but it use mppe stateless).
When i try to connect with WindowsXP Client i need mppe-stateful or it fail at
set up time, then when i use this settings i get this log:

Connect time 0.0 minutes.
Sent 84 bytes, received 120 bytes.
Modem hangup
Plugin rp-pppoe.so loaded.
RP-PPPoE plugin version 3.3 compiled against pppd 2.4.4
Plugin radius.so loaded.
RADIUS plugin initialized.
Plugin /etc/ppp/plugins/rp-pppoe.so loaded.
RP-PPPoE plugin version 3.3 compiled against pppd 2.4.4
using channel 93
Using interface ppp0
Connect: ppp0 <--> eth0
sent [LCP ConfReq id=0x1 <mru 1480> <auth chap MS-v2> <magic 0xf80e0eee>]
rcvd [LCP ConfReq id=0x0 <mru 1480> <magic 0x44c81073> <callback CBCP>]
sent [LCP ConfRej id=0x0 <callback CBCP>]
rcvd [LCP ConfAck id=0x1 <mru 1480> <auth chap MS-v2> <magic 0xf80e0eee>]
rcvd [LCP ConfReq id=0x1 <mru 1480> <magic 0x44c81073>]
sent [LCP ConfAck id=0x1 <mru 1480> <magic 0x44c81073>]
sent [LCP EchoReq id=0x0 magic=0xf80e0eee]
sent [CHAP Challenge id=0xaf <9834fec3e3953b0dd6437afa94d5c64f>, name = "PPPoE-R"]
rcvd [LCP Ident id=0x2 magic=0x44c81073 "MSRASV5.10"]
rcvd [LCP Ident id=0x3 magic=0x44c81073 "MSRAS-0-HTS91-PORTMS"]
rcvd [LCP EchoRep id=0x0 magic=0x44c81073]
rcvd [CHAP Response id=0xaf
<439bafda9a64ee5abc796eb04697e3990000000000000000b5f6b8a8559ef7aec1498c543cf8559bc65598f91ed96aa100>,
name = "t2OyoEA9"]
sent [CHAP Success id=0xaf "S=5A7D3E7B78F49C15F25B3D54570E2B67AAB7704F"]
peer from calling number 00:17:08:32:F5:0A authorized
sent [CCP ConfReq id=0x1 <mppe +H -M +S +L -D -C>]
rcvd [CCP ConfReq id=0x4 <mppe -H -M +S -L -D +C>]
sent [CCP ConfNak id=0x4 <mppe -H -M +S -L -D -C>]
rcvd [IPCP ConfReq id=0x5 <compress VJ 0f 01> <addr 0.0.0.0> <ms-dns1 0.0.0.0>
<ms-wins 0.0.0.0> <ms-dns3 0.0.0.0> <ms-wins 0.0.0.0>]
sent [IPCP TermAck id=0x5]
rcvd [CCP ConfNak id=0x1 <mppe -H -M +S -L -D -C>]
sent [CCP ConfReq id=0x2 <mppe -H -M +S -L -D -C>]
rcvd [CCP ConfReq id=0x6 <mppe -H -M +S -L -D -C>]
sent [CCP ConfAck id=0x6 <mppe -H -M +S -L -D -C>]
rcvd [CCP ConfAck id=0x2 <mppe -H -M +S -L -D -C>]
MPPE 128-bit stateful compression enabled
sent [IPCP ConfReq id=0x1 <addr 10.0.0.1>]
rcvd [IPCP ConfAck id=0x1 <addr 10.0.0.1>]
rcvd [IPCP ConfReq id=0x7 <compress VJ 0f 01> <addr 0.0.0.0> <ms-dns1 0.0.0.0>
<ms-wins 0.0.0.0> <ms-dns3 0.0.0.0> <ms-wins 0.0.0.0>]
sent [IPCP ConfRej id=0x7 <compress VJ 0f 01> <ms-wins 0.0.0.0> <ms-wins 0.0.0.0>]
rcvd [IPCP ConfReq id=0x8 <addr 0.0.0.0> <ms-dns1 0.0.0.0> <ms-dns3 0.0.0.0>]
sent [IPCP ConfNak id=0x8 <addr 10.67.7.5> <ms-dns1 212.216.112.112> <ms-dns3
192.168.3.39>]
rcvd [IPCP ConfReq id=0x9 <addr 10.67.7.5> <ms-dns1 212.216.112.112> <ms-dns3
192.168.3.39>]
sent [IPCP ConfAck id=0x9 <addr 10.67.7.5> <ms-dns1 212.216.112.112> <ms-dns3
192.168.3.39>]
local  IP address 10.0.0.1
remote IP address 10.67.7.5
Script /etc/ppp/ip-up started (pid 5510)
Script /etc/ppp/ip-up finished (pid 5510), status = 0x1
rcvd [proto=0xe17] 45 10 ae 8b 70 45 f3 45 76 21 78 23 79 1e 6a d8 eb e7 6d 2a
5b 1a cc 9c b4 6a 41 11 4b 06 9a 4b ...
Unsupported protocol 0xe17 received
sent [LCP ProtRej id=0x2 0e 17 45 10 ae 8b 70 45 f3 45 76 21 78 23 79 1e 6a d8
eb e7 6d 2a 5b 1a cc 9c b4 6a 41 11 4b 06 ...]
rcvd [proto=0x89] 7e d8 50 1f 9f 65 e3 95 f1 39 de 49 dc 30 3c fd 70 7a 46 88 d5
3f 62 03 88 90 76 ec c9 d9 88 bd ...
Unsupported protocol 0x89 received
sent [LCP ProtRej id=0x3 00 89 7e d8 50 1f 9f 65 e3 95 f1 39 de 49 dc 30 3c fd
70 7a 46 88 d5 3f 62 03 88 90 76 ec c9 d9 ...]
rcvd [proto=0x4f] bb 69 33 41 2f 71 c8 09 f2 14 fe f6 29 45 66 8b dc df 6a b2 79
6d d8 66 49 d7 c6 82 07 ec 9a 99 ...
Unsupported protocol 'IP6 Header Compression' (0x4f) received
sent [LCP ProtRej id=0x4 00 4f bb 69 33 41 2f 71 c8 09 f2 14 fe f6 29 45 66 8b
dc df 6a b2 79 6d d8 66 49 d7 c6 82 07 ec ...]
rcvd [proto=0x5045] c0 e5 fb 71 5b fc 71 c4 42 63 12 43 10 93 23 48 7a da fc 52
a2 53 c2 71 2d a8 ba 67 13 72 32 27 ...
Unsupported protocol 0x5045 received
sent [LCP ProtRej id=0x5 50 45 c0 e5 fb 71 5b fc 71 c4 42 63 12 43 10 93 23 48
7a da fc 52 a2 53 c2 71 2d a8 ba 67 13 72 ...]
rcvd [proto=0x4ea] 60 37 28 14 f5 86 09 24 b2 b5 4d df 2a b8 1d 7d bc 71 66 72
5f fc 73 e6 bf e5 ee 82 ad 04 b4 75 ...
Unsupported protocol 0x4ea received
sent [LCP ProtRej id=0x6 04 ea 60 37 28 14 f5 86 09 24 b2 b5 4d df 2a b8 1d 7d
bc 71 66 72 5f fc 73 e6 bf e5 ee 82 ad 04 ...]
rcvd [proto=0xc204] 10 92 44 80 8c ad a5 ba 3d cb 5a e3 a4 4b a7 07 ad 9b 67 b4
5b 96 04 da 3a c1 04 6e 92 c5 09 36 ...
Unsupported protocol 0xc204 received
sent [LCP ProtRej id=0x7 c2 04 10 92 44 80 8c ad a5 ba 3d cb 5a e3 a4 4b a7 07
ad 9b 67 b4 5b 96 04 da 3a c1 04 6e 92 c5 ...]
rcvd [proto=0x148d] 90 3c 99 0f 84 ba 9d bc 63 86 11 a3 ed 87 c4 05 8c ac 47 d7
d0 7b 58 6e d9 9f b6 22 f6 34 20 b2 ...
Unsupported protocol 0x148d received
sent [LCP ProtRej id=0x8 14 8d 90 3c 99 0f 84 ba 9d bc 63 86 11 a3 ed 87 c4 05
8c ac 47 d7 d0 7b 58 6e d9 9f b6 22 f6 34 ...]
rcvd [proto=0x363b] bb 62 e7 ae e2 db a6 a0 58 49 7b f0 54 f4 15 7f 3e 09 f5 6b
02 22 56 1c f7 48 6b f9 45 09 cf 04 ...
Unsupported protocol 0x363b received
sent [LCP ProtRej id=0x9 36 3b bb 62 e7 ae e2 db a6 a0 58 49 7b f0 54 f4 15 7f
3e 09 f5 6b 02 22 56 1c f7 48 6b f9 45 09 ...]
rcvd [proto=0xc5] 1a d8 8c bf a7 72 fd 79 c6 f7 30 97 c6 f2 22 d8 31 e2 2f 38 b7
05 40 77 ec 24 29 35 8e f6 75 2e ...
Unsupported protocol 0xc5 received
continue...

Steps to reproduce:
always if i use mppe, if i downgrade the kernel and patch it with mppe-mppc
patch all wrks fine, but mppc flag is off, so i think it is a problem in kernel
implementation of mppe statefull!

Thanks
Jack

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
