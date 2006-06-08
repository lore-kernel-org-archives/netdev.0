From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 6666] New: invalid tcp socket connection to
 windows stacks
Date: Thu, 8 Jun 2006 10:36:27 -0700
Message-ID: <20060608103627.23cfc83a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: technik@power-netz.de,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:47238 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964882AbWFHRgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 13:36:40 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 8 Jun 2006 05:23:04 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 6666] New: invalid tcp socket connection to windows stacks


http://bugzilla.kernel.org/show_bug.cgi?id=6666

           Summary: invalid tcp socket connection to windows stacks
    Kernel Version: 2.6.17.rc3-rc6
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: technik@power-netz.de


Most recent kernel where this bug did not occur:

2.6.16 stable

Distribution:
none. static kernel compiled directly out of the box.

Hardware Environment:
dual Xeon 2.66 512kB 1024MB networks e1000 e1000 e100
dual Xeon 3.20 2048kB 2048MB networks e1000 sky2

Software Environment:
problem occurs in kernel version 2.6.17rc3, 2.6.17rc6
problem does NOT occur in kernel version 2.6.16

Problem Description:

The kernel sends an ack to the windows stack after sync has been
replied, but theres no answere to this ack(1) and the kernel sends
a FIN packet after connection timeout. Now the windowsstack sends 
an ack(2) and a FIN and the connections ends.

It takes a while for the linux kernel to send the fin, we have shorten 
this in our tcpdump a bit.

connections to other windowssystems i.e. throu a dsl router or other linux 
based computers are working as expected. 

It is a very! special bug which you are maybe not able to reproduce. 

that's why i added the ip adress to test with. As far as i know, the ip
belongs to an exchange server in a home network somewhere in switzerland.

You can use it freely as it acts as a public mailserver for the domain.

Problem occurs independently of "Rx Polling"/"NAPI" and "Packet Split" 
settings.

Steps to reproduce:

You need TCPDUMP and NETCAT ( nc ).

1) tcpdump -w /tmp/log -s 2000 host  212.90.215.40  &
2) nc 212.90.215.40 25

If it's buggy you get :

11:24:15.021572 d59.x-mailer.de.59959 >
cust.static.212-90-215-40.cybernet.ch.smtp: S 2028538653:2028538653(0) win 5840
<mss 1460,sackOK,timestamp 243108498 0,nop,wscale 7> (DF)
11:24:15.076329 cust.static.212-90-215-40.cybernet.ch.smtp >
d59.x-mailer.de.59959: S 2328498080:2328498080(0) ack 2028538654 win 16384 <mss
1400,nop,wscale 0,nop,nop,timestamp 0
0,nop,nop,sackOK>
11:24:15.076352 d59.x-mailer.de.59959 >
cust.static.212-90-215-40.cybernet.ch.smtp: . ack 1 win 46 <nop,nop,timestamp
243108503 0> (DF)
11:24:21.926186 d59.x-mailer.de.59959 >
cust.static.212-90-215-40.cybernet.ch.smtp: F 1:1(0) ack 1 win 46
<nop,nop,timestamp 243109188 0> (DF)
11:24:21.972106 cust.static.212-90-215-40.cybernet.ch.smtp >
d59.x-mailer.de.59959: . ack 2 win 65535 <nop,nop,timestamp 19121191 243109188> (DF)
11:24:21.973980 cust.static.212-90-215-40.cybernet.ch.smtp >
d59.x-mailer.de.59959: F 116:116(0) ack 2 win 65535 <nop,nop,timestamp 19121191
243109188> (DF)
11:24:21.973999 d59.x-mailer.de.59959 >
cust.static.212-90-215-40.cybernet.ch.smtp: R 2028538655:2028538655(0) win 0 (DF)   

### you should get kind of this:

13:56:37.203297 d59.x-mailer.de.43286 >
cust.static.212-90-215-40.cybernet.ch.smtp: S 1489507409:1489507409(0) win 5840
<mss 1460,sackOK,timestamp 16627469 0,nop,wscale 2> (DF)
13:56:37.250827 cust.static.212-90-215-40.cybernet.ch.smtp >
d59.x-mailer.de.43286: S 783498912:783498912(0) ack 1489507410 win 16384 <mss
1400,nop,wscale 0,nop,nop,timestamp 0 0,nop,nop,sackOK>
13:56:37.250888 d59.x-mailer.de.43286 >
cust.static.212-90-215-40.cybernet.ch.smtp: . ack 1 win 1460 <nop,nop,timestamp
16627473 0> (DF)
13:56:37.292170 cust.static.212-90-215-40.cybernet.ch.smtp >
d59.x-mailer.de.43286: P 1:116(115) ack 1 win 65535 <nop,nop,timestamp 20940584
16627469> (DF)
13:56:37.292207 d59.x-mailer.de.43286 >
cust.static.212-90-215-40.cybernet.ch.smtp: . ack 116 win 1460
<nop,nop,timestamp 16627478 20940584> (DF)
13:56:39.373383 d59.x-mailer.de.43286 >
cust.static.212-90-215-40.cybernet.ch.smtp: F 1:1(0) ack 116 win 1460
<nop,nop,timestamp 16627686 20940584> (DF)
13:56:39.413075 cust.static.212-90-215-40.cybernet.ch.smtp >
d59.x-mailer.de.43286: . ack 2 win 65535 <nop,nop,timestamp 20940605 16627686> (DF)
13:56:39.414449 cust.static.212-90-215-40.cybernet.ch.smtp >
d59.x-mailer.de.43286: F 116:116(0) ack 2 win 65535 <nop,nop,timestamp 20940605
16627686> (DF)
13:56:39.414464 d59.x-mailer.de.43286 >
cust.static.212-90-215-40.cybernet.ch.smtp: . ack 117 win 1460
<nop,nop,timestamp 16627690 20940605> (DF)

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
