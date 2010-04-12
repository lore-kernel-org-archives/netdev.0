From: stephen mulcahy <smulcahy@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Mon, 12 Apr 2010 14:19:26 +0100
Message-ID: <4BC31DDE.7010005@gmail.com>
References: <4B9E6C60.7030300@atlanticlinux.ie>	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>		 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie>	 <1270942606.6179.64.camel@localhost> <4BC2EF88.3060203@atlanticlinux.ie>	  <4BC31486.1090603@gmail.com> <1271076426.16881.21.camel@edumazet-laptop> <4BC31AA0.5070006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep20-int.chello.at ([62.179.121.40]:39812 "EHLO
	viefep20-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab0DLNTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 09:19:34 -0400
In-Reply-To: <4BC31AA0.5070006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stephen mulcahy wrote:
>> Are both way non functional (RX and TX), or only one side ?
> 
> Whats the best way of testing this? (tcpdump listening on both hosts and 
> then running pings between the systems?)


stephen mulcahy wrote:
 >> Are both way non functional (RX and TX), or only one side ?
 >
 > Whats the best way of testing this? (tcpdump listening on both hosts and
 > then running pings between the systems?)

On one of the nodes that is in the malfunctioning state (node05), I ran

ssh node20

and grabbed the following output from running tcpdump on node20

root@node20:~# tcpdump host node20 and node05
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
14:12:59.612626 IP node05.webstar.cnet.36295 > node20.ssh: Flags [S], 
seq 3677858646, win 5840, options [mss 1460,sackOK,TS val 1599534 ecr 
0,nop,wscale 7], length 0
14:12:59.612656 IP node20.ssh > node05.webstar.cnet.36295: Flags [S.], 
seq 3610575850, ack 3677858647, win 5792, options [mss 1460,sackOK,TS 
val 1598775 ecr 1599534,nop,wscale 7], length 0
14:12:59.612718 IP node05.webstar.cnet.36295 > node20.ssh: Flags [.], 
ack 1, win 46, options [nop,nop,TS val 1599534 ecr 1598775], length 0
14:12:59.617434 IP node20.ssh > node05.webstar.cnet.36295: Flags [P.], 
seq 1:33, ack 1, win 46, options [nop,nop,TS val 1598776 ecr 1599534], 
length 32
14:12:59.617522 IP node05.webstar.cnet.36295 > node20.ssh: Flags [.], 
ack 33, win 46, options [nop,nop,TS val 1599535 ecr 1598776], length 0
14:12:59.617609 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], 
seq 1:33, ack 33, win 46, options [nop,nop,TS val 1599535 ecr 1598776], 
length 32
14:12:59.820434 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], 
seq 4294936586:4294936618, ack 2620194849, win 46, options [nop,nop,TS 
val 1599586 ecr 1598776], length 32
14:13:00.229069 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], 
seq 4294961734:4294961766, ack 3928358945, win 46, options [nop,nop,TS 
val 1599688 ecr 1598776], length 32
14:13:01.044396 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], 
seq 4294964167:4294964199, ack 410320929, win 46, options [nop,nop,TS 
val 1599892 ecr 1598776], length 32
14:13:02.676308 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], 
seq 1:33, ack 33, win 46, options [nop,nop,TS val 1600300 ecr 1598776], 
length 32
14:13:05.940804 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], 
seq 17294:17326, ack 3045851169, win 46, options [nop,nop,TS val 1601116 
ecr 1598776], length 32
14:13:12.468484 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], 
seq 17294:17326, ack 3045851169, win 46, options [nop,nop,TS val 1602748 
ecr 1598776], length 32
14:13:23.846891 IP node20.ssh > node05.webstar.cnet.36084: Flags [F.], 
seq 2093054475, ack 2175389538, win 46, options [nop,nop,TS val 1604834 
ecr 1575591], length 0
14:13:23.847278 IP node05.webstar.cnet.36084 > node20.ssh: Flags [R], 
seq 2175389538, win 0, length 0
14:13:25.523850 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], 
seq 1:33, ack 33, win 46, options [nop,nop,TS val 1606012 ecr 1598776], 
length 32
14:13:50.127509 IP node20.ssh > node05.webstar.cnet.36143: Flags [F.], 
seq 2526196657, ack 2590340885, win 46, options [nop,nop,TS val 1611404 
ecr 1582161], length 0
14:13:50.127879 IP node05.webstar.cnet.36143 > node20.ssh: Flags [R], 
seq 2590340885, win 0, length 0
14:13:51.633934 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], 
seq 4294963190:4294963222, ack 9830433, win 46, options [nop,nop,TS val 
1612540 ecr 1598776], length 32
14:13:55.125525 ARP, Request who-has node05.webstar.cnet tell node20, 
length 28
14:13:55.125886 ARP, Reply node05.webstar.cnet is-at 00:30:48:ce:dc:02 
(oui Unknown), length 46
14:14:43.855380 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], 
seq 1:33, ack 33, win 46, options [nop,nop,TS val 1625596 ecr 1598776], 
length 32
14:14:48.855143 ARP, Request who-has node20 tell node05.webstar.cnet, 
length 46
14:14:48.855469 ARP, Reply node20 is-at 00:30:48:ce:de:34 (oui Unknown), 
length 28
14:14:59.617675 IP node20.ssh > node05.webstar.cnet.36295: Flags [F.], 
seq 33, ack 1, win 46, options [nop,nop,TS val 1628777 ecr 1599535], 
length 0
14:14:59.618202 IP node05.webstar.cnet.36295 > node20.ssh: Flags [FP.], 
seq 4294959654:4294960446, ack 3930456098, win 46, options [nop,nop,TS 
val 1629536 ecr 1628777], length 792
14:14:59.821527 IP node20.ssh > node05.webstar.cnet.36295: Flags [F.], 
seq 33, ack 1, win 46, options [nop,nop,TS val 1628828 ecr 1599535], 
length 0
14:14:59.821598 IP node05.webstar.cnet.36295 > node20.ssh: Flags [.], 
ack 34, win 46, options [nop,nop,TS val 1629587 ecr 1628828,nop,nop,sack 
1 {33:34}], length 0
^C^
27 packets captured
31 packets received by filter
0 packets dropped by kernel


I then did ifdown and ifup on node05 and again ran

ssh node20

and grabbed the following output from running tcpdump on node20

root@node20:~# tcpdump host node20 and node05
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
14:15:50.626410 IP node05.webstar.cnet.36690 > node20.ssh: Flags [S], 
seq 2044900531, win 5840, options [mss 1460,sackOK,TS val 1642289 ecr 
0,nop,wscale 7], length 0
14:15:50.626441 IP node20.ssh > node05.webstar.cnet.36690: Flags [S.], 
seq 1976694445, ack 2044900532, win 5792, options [mss 1460,sackOK,TS 
val 1641529 ecr 1642289,nop,wscale 7], length 0
14:15:50.626482 IP node05.webstar.cnet.36690 > node20.ssh: Flags [.], 
ack 1, win 46, options [nop,nop,TS val 1642289 ecr 1641529], length 0
14:15:50.631138 IP node20.ssh > node05.webstar.cnet.36690: Flags [P.], 
seq 1:33, ack 1, win 46, options [nop,nop,TS val 1641530 ecr 1642289], 
length 32
14:15:50.631218 IP node05.webstar.cnet.36690 > node20.ssh: Flags [.], 
ack 33, win 46, options [nop,nop,TS val 1642290 ecr 1641530], length 0
14:15:50.631267 IP node05.webstar.cnet.36690 > node20.ssh: Flags [P.], 
seq 1:33, ack 33, win 46, options [nop,nop,TS val 1642290 ecr 1641530], 
length 32
14:15:50.631281 IP node20.ssh > node05.webstar.cnet.36690: Flags [.], 
ack 33, win 46, options [nop,nop,TS val 1641530 ecr 1642290], length 0
14:15:50.631367 IP node05.webstar.cnet.36690 > node20.ssh: Flags [P.], 
seq 33:825, ack 33, win 46, options [nop,nop,TS val 1642290 ecr 
1641530], length 792
14:15:50.631376 IP node20.ssh > node05.webstar.cnet.36690: Flags [.], 
ack 825, win 58, options [nop,nop,TS val 1641530 ecr 1642290], length 0
14:15:50.631808 IP node20.ssh > node05.webstar.cnet.36690: Flags [P.], 
seq 33:817, ack 825, win 58, options [nop,nop,TS val 1641530 ecr 
1642290], length 784
14:15:50.631950 IP node05.webstar.cnet.36690 > node20.ssh: Flags [P.], 
seq 825:849, ack 817, win 58, options [nop,nop,TS val 1642290 ecr 
1641530], length 24
14:15:50.633353 IP node20.ssh > node05.webstar.cnet.36690: Flags [P.], 
seq 817:969, ack 849, win 58, options [nop,nop,TS val 1641530 ecr 
1642290], length 152
14:15:50.633932 IP node05.webstar.cnet.36690 > node20.ssh: Flags [P.], 
seq 849:993, ack 969, win 71, options [nop,nop,TS val 1642291 ecr 
1641530], length 144
14:15:50.637998 IP node20.ssh > node05.webstar.cnet.36690: Flags [P.], 
seq 969:1689, ack 993, win 70, options [nop,nop,TS val 1641532 ecr 
1642291], length 720
14:15:50.676465 IP node05.webstar.cnet.36690 > node20.ssh: Flags [.], 
ack 1689, win 83, options [nop,nop,TS val 1642302 ecr 1641532], length 0
14:16:09.776134 IP node05.webstar.cnet.49671 > node20.50060: Flags [S], 
seq 2348078217, win 5840, options [mss 1460,sackOK,TS val 1647077 ecr 
0,nop,wscale 7], length 0
14:16:09.776498 IP node20.50060 > node05.webstar.cnet.49671: Flags [R.], 
seq 0, ack 2348078218, win 0, length 0
^C
17 packets captured
21 packets received by filter
0 packets dropped by kernel


Does that help?
