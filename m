From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Mon, 12 Apr 2010 17:24:22 +0200
Message-ID: <1271085862.16881.38.camel@edumazet-laptop>
References: <4B9E6C60.7030300@atlanticlinux.ie>
	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>
	 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie>
	 <1270942606.6179.64.camel@localhost> <4BC2EF88.3060203@atlanticlinux.ie>
	 <4BC31486.1090603@gmail.com> <1271076426.16881.21.camel@edumazet-laptop>
	 <4BC31AA0.5070006@gmail.com>  <4BC31DDE.7010005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: stephen mulcahy <smulcahy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:48353 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776Ab0DLPYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 11:24:32 -0400
Received: by bwz19 with SMTP id 19so42201bwz.21
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 08:24:31 -0700 (PDT)
In-Reply-To: <4BC31DDE.7010005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 avril 2010 =C3=A0 14:19 +0100, stephen mulcahy a =C3=A9crit=
 :

> Does that help?

Well, yes, because it seems a TCP problem.

root@node20:~# tcpdump host node20 and node05
tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
14:12:59.612626 IP node05.webstar.cnet.36295 > node20.ssh: Flags [S], s=
eq 3677858646, win 5840, options [mss 1460,sackOK,TS val 1599534 ecr 0,=
nop,wscale 7], length 0
14:12:59.612656 IP node20.ssh > node05.webstar.cnet.36295: Flags [S.], =
seq 3610575850, ack 3677858647, win 5792, options [mss 1460,sackOK,TS v=
al 1598775 ecr 1599534,nop,wscale 7], length 0
14:12:59.612718 IP node05.webstar.cnet.36295 > node20.ssh: Flags [.], a=
ck 1, win 46, options [nop,nop,TS val 1599534 ecr 1598775], length 0
14:12:59.617434 IP node20.ssh > node05.webstar.cnet.36295: Flags [P.], =
seq 1:33, ack 1, win 46, options [nop,nop,TS val 1598776 ecr 1599534], =
length 32
14:12:59.617522 IP node05.webstar.cnet.36295 > node20.ssh: Flags [.], a=
ck 33, win 46, options [nop,nop,TS val 1599535 ecr 1598776], length 0
14:12:59.617609 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], =
seq 1:33, ack 33, win 46, options [nop,nop,TS val 1599535 ecr 1598776],=
 length 32

All following xmitted frames are completely out of sync, this makes no =
sense.

Sequence number went backward.

14:12:59.820434 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], =
seq 4294936586:4294936618, ack 2620194849, win 46, options [nop,nop,TS =
val 1599586 ecr 1598776], length 32
14:13:00.229069 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], =
seq 4294961734:4294961766, ack 3928358945, win 46, options [nop,nop,TS =
val 1599688 ecr 1598776], length 32
14:13:01.044396 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], =
seq 4294964167:4294964199, ack 410320929, win 46, options [nop,nop,TS v=
al 1599892 ecr 1598776], length 32


14:13:02.676308 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], =
seq 1:33, ack 33, win 46, options [nop,nop,TS val 1600300 ecr 1598776],=
 length 32
14:13:05.940804 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], =
seq 17294:17326, ack 3045851169, win 46, options [nop,nop,TS val 160111=
6 ecr 1598776], length 32
14:13:12.468484 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], =
seq 17294:17326, ack 3045851169, win 46, options [nop,nop,TS val 160274=
8 ecr 1598776], length 32
14:13:25.523850 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], =
seq 1:33, ack 33, win 46, options [nop,nop,TS val 1606012 ecr 1598776],=
 length 32
14:13:51.633934 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], =
seq 4294963190:4294963222, ack 9830433, win 46, options [nop,nop,TS val=
 1612540 ecr 1598776], length 32
14:14:43.855380 IP node05.webstar.cnet.36295 > node20.ssh: Flags [P.], =
seq 1:33, ack 33, win 46, options [nop,nop,TS val 1625596 ecr 1598776],=
 length 32
14:14:59.617675 IP node20.ssh > node05.webstar.cnet.36295: Flags [F.], =
seq 33, ack 1, win 46, options [nop,nop,TS val 1628777 ecr 1599535], le=
ngth 0
14:14:59.618202 IP node05.webstar.cnet.36295 > node20.ssh: Flags [FP.],=
 seq 4294959654:4294960446, ack 3930456098, win 46, options [nop,nop,TS=
 val 1629536 ecr 1628777], length 792
14:14:59.821527 IP node20.ssh > node05.webstar.cnet.36295: Flags [F.], =
seq 33, ack 1, win 46, options [nop,nop,TS val 1628828 ecr 1599535], le=
ngth 0
14:14:59.821598 IP node05.webstar.cnet.36295 > node20.ssh: Flags [.], a=
ck 34, win 46, options [nop,nop,TS val 1629587 ecr 1628828,nop,nop,sack=
 1 {33:34}], length 0

Do you have some netfilters rules ?


