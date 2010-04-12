From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Mon, 12 Apr 2010 18:59:41 +0200
Message-ID: <1271091581.16881.41.camel@edumazet-laptop>
References: <4B9E6C60.7030300@atlanticlinux.ie>
	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>
	 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie>
	 <1270942606.6179.64.camel@localhost> <4BC2EF88.3060203@atlanticlinux.ie>
	 <4BC31486.1090603@gmail.com> <1271076426.16881.21.camel@edumazet-laptop>
	 <4BC31AA0.5070006@gmail.com> <4BC31DDE.7010005@gmail.com>
	 <1271085862.16881.38.camel@edumazet-laptop>  <4BC3461D.3070002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: stephen mulcahy <smulcahy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:51721 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752715Ab0DLQ7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 12:59:47 -0400
Received: by bwz19 with SMTP id 19so3946bwz.21
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 09:59:45 -0700 (PDT)
In-Reply-To: <4BC3461D.3070002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 avril 2010 =C3=A0 17:11 +0100, stephen mulcahy a =C3=A9crit=
 :
> Eric Dumazet wrote:
> > Le lundi 12 avril 2010 =C3=A0 14:19 +0100, stephen mulcahy a =C3=A9=
crit :
> >=20
> > Do you have some netfilters rules ?
> >=20
>=20
> Hi Eric,
>=20
> I don't have any netfilters rules:
>=20
> root@node34:~# for table in filter nat mangle raw; do iptables -t $ta=
ble=20
> -L; done
> Chain INPUT (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain FORWARD (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain OUTPUT (policy ACCEPT)
> target     prot opt source               destination
> Chain PREROUTING (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain POSTROUTING (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain OUTPUT (policy ACCEPT)
> target     prot opt source               destination
> Chain PREROUTING (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain INPUT (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain FORWARD (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain OUTPUT (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain POSTROUTING (policy ACCEPT)
> target     prot opt source               destination
> Chain PREROUTING (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain OUTPUT (policy ACCEPT)
> target     prot opt source               destination
>=20
>=20
> I re-ran this on the 2.6.32 kernel (with the 2.6.32 forcedeth module)=
=20
> just in case that was screwing something up.
>=20
> node33 is in the unresponsive state this time. I'm running tcpdump on=
=20
> node34. on node33 I try to ssh to node34 (using ip address of node34)=
=2E I=20
> note that I can ping between node33 and node34.
>=20
> root@node34:~# tcpdump -v host node34 and node33
> tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size=
 96=20
> bytes
> 17:05:19.622384 IP (tos 0x0, ttl 64, id 21435, offset 0, flags [DF],=20
> proto TCP (6), length 60)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [S], cksum 0xb994=20
> (correct), seq 1675314077, win 5840, options [mss 1460,sackOK,TS val=20
> 331814 ecr 0,nop,wscale 7], length 0
> 17:05:19.622754 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], prot=
o=20
> TCP (6), length 60)
>      node34.ssh > node33.webstar.cnet.43653: Flags [S.], cksum 0x9d81=
=20
> (correct), seq 1669769379, ack 1675314078, win 5792, options [mss=20
> 1460,sackOK,TS val 331779 ecr 331814,nop,wscale 7], length 0
> 17:05:19.622813 IP (tos 0x0, ttl 64, id 21436, offset 0, flags [DF],=20
> proto TCP (6), length 52)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [.], cksum 0xe2bf=20
> (correct), ack 1, win 46, options [nop,nop,TS val 331814 ecr 331779],=
=20
> length 0
> 17:05:19.627666 IP (tos 0x0, ttl 64, id 47271, offset 0, flags [DF],=20
> proto TCP (6), length 84)
>      node34.ssh > node33.webstar.cnet.43653: Flags [P.], seq 1:33, ac=
k=20
> 1, win 46, options [nop,nop,TS val 331780 ecr 331814], length 32
> 17:05:19.627748 IP (tos 0x0, ttl 64, id 21437, offset 0, flags [DF],=20
> proto TCP (6), length 52)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [.], cksum 0xe29c=20
> (correct), ack 33, win 46, options [nop,nop,TS val 331816 ecr 331780]=
,=20
> length 0
> 17:05:19.627833 IP (tos 0x0, ttl 64, id 21438, offset 0, flags [DF],=20
> proto TCP (6), length 84, bad cksum 1f8a (->d189)!)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [P.], seq=20
> 23413:23445, ack 2749038625, win 46, options [nop,nop,TS val 331816 e=
cr=20
> 331780], length 32
> 17:05:19.831634 IP (tos 0x0, ttl 64, id 21439, offset 0, flags [DF],=20
> proto TCP (6), length 84, bad cksum d189 (->d188)!)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [P.], seq 1:33, ac=
k=20
> 33, win 46, options [nop,nop,TS val 331867 ecr 331780], length 32
> 17:05:20.239603 IP (tos 0x0, ttl 64, id 21440, offset 0, flags [DF],=20
> proto TCP (6), length 84, bad cksum 15c6 (->d187)!)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [P.], seq=20
> 30492:30524, ack 809893921, win 46, options [nop,nop,TS val 331969 ec=
r=20
> 331780], length 32
> 17:05:21.055534 IP (tos 0x0, ttl 64, id 21441, offset 0, flags [DF],=20
> proto TCP (6), length 84, bad cksum d187 (->d186)!)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [P.], seq 1:33, ac=
k=20
> 33, win 46, options [nop,nop,TS val 332173 ecr 331780], length 32
> 17:05:22.687386 IP (tos 0x0, ttl 64, id 21442, offset 0, flags [DF],=20
> proto TCP (6), length 84, bad cksum d186 (->d185)!)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [P.], seq 1:33, ac=
k=20
> 33, win 46, options [nop,nop,TS val 332581 ecr 331780], length 32
> 17:05:25.950935 IP (tos 0x0, ttl 64, id 21443, offset 0, flags [DF],=20
> proto TCP (6), length 84, bad cksum 15c4 (->d184)!)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [P.], seq=20
> 30492:30524, ack 809893921, win 46, options [nop,nop,TS val 333397 ec=
r=20
> 331780], length 32
> 17:05:32.478527 IP (tos 0x0, ttl 64, id 21444, offset 0, flags [DF],=20
> proto TCP (6), length 84, bad cksum c01 (->d183)!)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [P.], seq=20
> 43997:44029, ack 1311047713, win 46, options [nop,nop,TS val 335029 e=
cr=20
> 331780], length 32
> 17:05:45.533370 IP (tos 0x0, ttl 64, id 21445, offset 0, flags [DF],=20
> proto TCP (6), length 84, bad cksum 23d (->d182)!)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [P.], seq 3348:338=
0,=20
> ack 4054450209, win 46, options [nop,nop,TS val 338293 ecr 331780],=20
> length 32
> 17:06:08.719187 IP (tos 0x0, ttl 64, id 27660, offset 0, flags [DF],=20
> proto TCP (6), length 1500, bad cksum 5360 (->b3b3)!)
>      node33.webstar.cnet.50060 > node34.35725: Flags [.], seq=20
> 1203473738:1203475186, ack 1191452767, win 54, options [nop,nop,TS va=
l=20
> 344089 ecr 256770], length 1448
> 17:06:11.643080 IP (tos 0x0, ttl 64, id 21446, offset 0, flags [DF],=20
> proto TCP (6), length 84, bad cksum e4f2 (->d181)!)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [P.], seq=20
> 47331:47363, ack 4110811169, win 46, options [nop,nop,TS val 344821 e=
cr=20
> 331780], length 32
> 17:06:13.715233 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has=20
> node34 tell node33.webstar.cnet, length 46
> 17:06:13.715257 ARP, Ethernet (len 6), IPv4 (len 4), Reply node34 is-=
at=20
> 00:30:48:f0:06:72 (oui Unknown), length 28
> 17:07:03.866492 IP (tos 0x0, ttl 64, id 21447, offset 0, flags [DF],=20
> proto TCP (6), length 84, bad cksum b413 (->d180)!)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [P.], seq=20
> 28939:28971, ack 1913782305, win 46, options [nop,nop,TS val 357877 e=
cr=20
> 331780], length 32
> 17:07:08.862055 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has=20
> node34 tell node33.webstar.cnet, length 46
> 17:07:08.862370 ARP, Ethernet (len 6), IPv4 (len 4), Reply node34 is-=
at=20
> 00:30:48:f0:06:72 (oui Unknown), length 28
> 17:07:19.627910 IP (tos 0x0, ttl 64, id 47272, offset 0, flags [DF],=20
> proto TCP (6), length 52)
>      node34.ssh > node33.webstar.cnet.43653: Flags [F.], cksum 0x6d6b=
=20
> (correct), seq 33, ack 1, win 46, options [nop,nop,TS val 361780 ecr=20
> 331816], length 0
> 17:07:19.628403 IP (tos 0x0, ttl 64, id 21448, offset 0, flags [DF],=20
> proto TCP (6), length 844, bad cksum aa4d (->ce87)!)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [FP.], seq=20
> 20399:21191, ack 2356871202, win 46, options [nop,nop,TS val 361818 e=
cr=20
> 361780], length 792
> 17:07:19.833456 IP (tos 0x0, ttl 64, id 47273, offset 0, flags [DF],=20
> proto TCP (6), length 52)
>      node34.ssh > node33.webstar.cnet.43653: Flags [F.], cksum 0x6d37=
=20
> (correct), seq 33, ack 1, win 46, options [nop,nop,TS val 361832 ecr=20
> 331816], length 0
> 17:07:19.833517 IP (tos 0x0, ttl 64, id 21449, offset 0, flags [DF],=20
> proto TCP (6), length 64)
>      node33.webstar.cnet.43653 > node34.ssh: Flags [.], cksum 0xa5e9=20
> (correct), ack 34, win 46, options [nop,nop,TS val 361870 ecr=20
> 361832,nop,nop,sack 1 {33:34}], length 0
>=20
> At this point, I see a "Connection closed by 10.141.0.34" message on=20
> node33 (from where I am attempting to ssh).
>=20
> Again, if I ifdown on node33 and ifup again - I can then see from nod=
e33=20
> to node34 without problems.
>=20

OK it seems forcedeth has problem with checksums ?

Try to change "ethtool -k eth0" settings ?

ethtool -K eth0 tso off tx off



