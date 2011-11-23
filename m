From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>
Subject: cache forver in 3.2.0-rc2-00400-g866d43c ?
Date: Wed, 23 Nov 2011 19:10:37 +0100
Message-ID: <201111231910.37190.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57465 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755597Ab1KWSKm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 13:10:42 -0500
Received: by bke11 with SMTP id 11so1888915bke.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 10:10:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

I'm using  my notebook in two different networks, suspending and resumi=
ng from=20
ram between.

Network A (192.168.1.0/24) has server with IP 87.204.99.133 in the same=
 lan.=20
Now when I suspend, go to totally different network B (different provid=
er,=20
different lan, 192.168.0.0/24) and resume then I'm unable to connect to=
=20
87.204.99.133.

Looks like network stack thinks that 87...133 is still directly reachab=
le on=20
eth1and I'm unable to make it forget that.

[root@t400 ~]# ip ne flush dev eth1; ip r flush table cache
[root@t400 ~]# ip r show table cache to 87.204.99.133
[root@t400 ~]# ping -c 1 87.204.99.133
PING 87.204.99.133 (87.204.99.133) 56(84) bytes of data.
=46rom 192.168.0.5: icmp_seq=3D1 Destination Host Unreachable

--- 87.204.99.133 ping statistics ---
1 packets transmitted, 0 received, +1 errors, 100% packet loss, time 0m=
s

zsh: exit 1     ping -c 1 87.204.99.133
[root@t400 ~]# ip r show table cache to 87.204.99.133
87.204.99.133 dev eth1  src 192.168.0.5
    cache <redirected>  ipid 0x2838 rtt 17ms rttvar 12ms cwnd 10
87.204.99.133 from 192.168.0.5 dev eth1
    cache <redirected>  ipid 0x2838 rtt 17ms rttvar 12ms cwnd 10
[root@t400 ~]# ip ne show to 87.204.99.133
87.204.99.133 dev eth1  FAILED

tcpdump in meantime sees this:
19:06:26.907153 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has=20
87.204.99.133 tell 192.168.0.5, length 28
19:06:27.908379 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has=20
87.204.99.133 tell 192.168.0.5, length 28
19:06:28.907084 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has=20
87.204.99.133 tell 192.168.0.5, length 28
19:06:29.907145 IP (tos 0xc0, ttl 64, id 34465, offset 0, flags [none],=
 proto=20
ICMP (1), length 112)
    192.168.0.5 > 192.168.0.5: ICMP host 87.204.99.133 unreachable, len=
gth 92
        IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto ICMP (1)=
,=20
length 84)
    192.168.0.5 > 87.204.99.133: ICMP echo request, id 17590, seq 1, le=
ngth 64

Any ideas?

Thanks,
--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
