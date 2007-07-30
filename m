From: "nano bug" <linnewbye@gmail.com>
Subject: Re: source interface ping bug ?
Date: Mon, 30 Jul 2007 11:46:33 +0300
Message-ID: <d39c36500707300146h72c72d69rce2f68595bdf6699@mail.gmail.com>
References: <d39c36500707270130j3eac7f44qb3a4c87496a1296b@mail.gmail.com>
	 <d39c36500707290448p599ff710hf79ba1911c818162@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:3796 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763049AbXG3Iqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 04:46:35 -0400
Received: by nf-out-0910.google.com with SMTP id g13so146233nfb
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2007 01:46:34 -0700 (PDT)
In-Reply-To: <d39c36500707290448p599ff710hf79ba1911c818162@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Can someone have a look a this and tell if it's kernel related or if I
posted this in the wrong place ? Thanks.

On 7/29/07, nano bug <linnewbye@gmail.com> wrote:
> Any news about this ?
>
> On 7/27/07, nano bug <linnewbye@gmail.com> wrote:
> > Hello there,
> >
> > I'm facing the following issue : when I try to ping using source
> > interface instead of a source ip address the ping utility starts to
> > send arp requests instead of icmp requests though the ip address I'm
> > pinging it's not in the subnets directly connected to my linux box.
> > I've noticed this situation since I upgraded from kernel 2.6.20 to
> > 2.6.21. On 2.6.20 and lower I haven't had this problem. Now I upgraded
> > to 2.6.22 but it's the same. I'm using latest iproute and iputils.
> > Here is an output of tcpdump when I try to ping an outside ip address,
> > like for example www.yahoo.com, using source interface :
> >
> > root@darkstar:~# uname -a
> > Linux darkstar 2.6.22 #1 Thu Jul 26 21:22:11 EEST 2007 i686 Pentium II
> > (Deschutes) GenuineIntel GNU/Linux
> >
> > root@darkstar:~# ip -V
> > ip utility, iproute2-ss070710
> > root@darkstar:~#
> >
> >
> > root@darkstar:~# ip address show dev eth2
> > 3: eth2: <BROADCAST,MULTICAST,NOTRAILERS,UP,LOWER_UP> mtu 1500 qdisc
> > pfifo_fast qlen 1000
> >    link/ether 00:90:27:0f:79:f3 brd ff:ff:ff:ff:ff:ff
> >    inet 86.106.19.75/23 brd 86.106.19.255 scope global eth2
> > root@darkstar:~# ip route get 87.248.113.14 from 86.106.19.75 oif eth2
> > 87.248.113.14 from 86.106.19.75 via 86.106.18.1 dev eth2
> >    cache  mtu 1500 advmss 1460 hoplimit 64
> > root@darkstar:~#
> >
> >
> > root@darkstar:~/iputils# ./ping -V
> > ping utility, iputils-sss20070202
> > root@darkstar:~/iputils# ./ping -I 86.106.19.75 87.248.113.14 -c 2
> > PING 87.248.113.14 (87.248.113.14) from 86.106.19.75 : 56(84) bytes of data.
> > 64 bytes from 87.248.113.14: icmp_seq=1 ttl=51 time=60.5 ms
> > 64 bytes from 87.248.113.14: icmp_seq=2 ttl=51 time=63.2 ms
> >
> > --- 87.248.113.14 ping statistics ---
> > 2 packets transmitted, 2 received, 0% packet loss, time 999ms
> > rtt min/avg/max/mdev = 60.574/61.924/63.274/1.350 ms
> > root@darkstar:~/iputils#
> >
> >
> > root@darkstar:~# tcpdump -i eth2 -vvv -n host 87.248.113.14 and host
> > 86.106.19.75
> > tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size 96 bytes
> > 01:18:09.572603 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF],
> > proto: ICMP (1), length: 84) 86.106.19.75 > 87.248.113.14: ICMP echo
> > request, id 27166, seq 1, length 64
> > 01:18:09.632861 IP (tos 0x0, ttl  51, id 6100, offset 0, flags [none],
> > proto: ICMP (1), length: 84) 87.248.113.14 > 86.106.19.75: ICMP echo
> > reply, id 27166, seq 1, length 64
> > 01:18:10.572746 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF],
> > proto: ICMP (1), length: 84) 86.106.19.75 > 87.248.113.14: ICMP echo
> > request, id 27166, seq 2, length 64
> > 01:18:10.634951 IP (tos 0x0, ttl  51, id 8790, offset 0, flags [none],
> > proto: ICMP (1), length: 84) 87.248.113.14 > 86.106.19.75: ICMP echo
> > reply, id 27166, seq 2, length 64
> >
> >
> >
> > using source interface :
> >
> > root@darkstar:~/iputils# ./ping -I eth2 87.248.113.14
> > PING 87.248.113.14 (87.248.113.14) from 86.106.19.75 eth2: 56(84) bytes of data.
> > From 86.106.19.75 icmp_seq=1 Destination Host Unreachable
> > From 86.106.19.75 icmp_seq=2 Destination Host Unreachable
> > From 86.106.19.75 icmp_seq=3 Destination Host Unreachable
> > From 86.106.19.75 icmp_seq=5 Destination Host Unreachable
> > From 86.106.19.75 icmp_seq=6 Destination Host Unreachable
> > From 86.106.19.75 icmp_seq=7 Destination Host Unreachable
> > From 86.106.19.75 icmp_seq=9 Destination Host Unreachable
> > From 86.106.19.75 icmp_seq=10 Destination Host Unreachable
> > From 86.106.19.75 icmp_seq=11 Destination Host Unreachable
> >
> > --- 87.248.113.14 ping statistics ---
> > 13 packets transmitted, 0 received, +9 errors, 100% packet loss, time 12006ms
> > , pipe 3
> > root@darkstar:~/iputils#
> >
> >
> > root@darkstar:~# tcpdump -i eth2 -vvv -n host 87.248.113.14 and host
> > 86.106.19.75
> > tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size 96 bytes
> > 01:19:24.292911 arp who-has 87.248.113.14 tell 86.106.19.75
> > 01:19:25.292897 arp who-has 87.248.113.14 tell 86.106.19.75
> > 01:19:26.292901 arp who-has 87.248.113.14 tell 86.106.19.75
> > 01:19:27.302906 arp who-has 87.248.113.14 tell 86.106.19.75
> > 01:19:28.302911 arp who-has 87.248.113.14 tell 86.106.19.75
> > 01:19:29.302912 arp who-has 87.248.113.14 tell 86.106.19.75
> > 01:19:31.302917 arp who-has 87.248.113.14 tell 86.106.19.75
> > 01:19:32.302921 arp who-has 87.248.113.14 tell 86.106.19.75
> > 01:19:33.302923 arp who-has 87.248.113.14 tell 86.106.19.75
> > 01:19:35.302932 arp who-has 87.248.113.14 tell 86.106.19.75
> > 01:19:36.302932 arp who-has 87.248.113.14 tell 86.106.19.75
> > 01:19:37.302939 arp who-has 87.248.113.14 tell 86.106.19.75
> >
> > 12 packets captured
> > 12 packets received by filter
> > 0 packets dropped by kernel
> > root@darkstar:~#
> >
> >
> > There is one exception though, it works when using eth0. I'm
> > administrating multiple linux boxes with 2 or 3 ethernet cards and if
> > I try pinging with eth0 it does send icmp like it should but when
> > specifying eth1 or eth2 is sends arp requests. The distro I'm using is
> > Slackware 12.0. I already reported this to the iputils maintainer and
> > he recommended to report it here. Thanks in advance.
> >
> > Regards.
> >
>
