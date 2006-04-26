From: Guenther Thomsen <gthomsen@bluearc.com>
Subject: sky2 driver problems in 2.6.17-rc2-git6 (was: Re: kernel panic (on DHCP discover?) in sky2 driver of 2.6.17-rc1)
Date: Tue, 25 Apr 2006 17:06:25 -0700
Message-ID: <200604251706.25617.gthomsen@bluearc.com>
References: <200604121442.56750.gthomsen@bluearc.com> <200604121526.51405.gthomsen@bluearc.com> <20060417111846.5a5deccc@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmimesweeper.bluearc.com ([63.203.197.133]:32010 "EHLO
	us-mimesweeper.terastack.bluearc.com") by vger.kernel.org with ESMTP
	id S932312AbWDZAJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 20:09:05 -0400
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060417111846.5a5deccc@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 17 April 2006 11:18, Stephen Hemminger wrote:
> I don't know what you are doing different, but my 2 port SysKonnect
> card is working fine.  Running SMP AMD64 and 2.6.17 latest.
>
> Showing full speed on both ports.
I missed that e-mail, sorry.

I just gave it another try, this time with 2.6.16.11 . One port works 
fine (so far, I just did very limited testing with ttcp). The second port 
does negotiate IP address via DHCP, but the packgages it receives 
seem to be garbled:

--8<--
       0x0000:  0000 6175 6469 7428 3131 3435 3939 3430  ..audit(11459940
        0x0010:  3031 2e39 3738 3a33 3829 3a20 7573 6572  01.978:38):.user
        0x0020:  2070 6964 3d33 3230 3920 7569 643d       .pid=3209.uid=
12:56:23.725090 00:00:00:00:00:00 > 30:6e:6d:00:00:00 null I (s=32,r=55,P) len=42
12:56:24.603274 00:00:21:00:00:00 > 00:00:00:00:00:00 null disc/C len=43
12:56:26.619326 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
12:56:28.635346 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
12:56:29.734046 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
12:56:29.865239 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
12:56:30.651371 00:00:00:00:00:00 > a6:00:00:00:4d:04, ethertype Unknown (0xe20c), length 60:
        0x0000:  0000 6175 6469 7428 3131 3435 3939 3436  ..audit(11459946
        0x0010:  3031 2e33 3639 3a34 3729 3a20 7573 6572  01.369:47):.user
        0x0020:  2070 6964 3d33 3239 3820 7569 643d       .pid=3298.uid=
12:56:30.916718 00:00:f0:71:61:00 > 28:37:03:5b:3a:00 null I (s=16,r=0,C) len=42
12:56:30.923558 00:00:21:00:00:00 > 00:00:00:00:00:00 null rnr (r=55,C) len=42
12:56:32.667413 00:00:d0:2e:30:42 > 10:60:61:00:00:00, ethertype Unknown (0x572b), length 60:
        0x0000:  0000 d675 0d00 0000 0000 0200 0000 0000  ...u............
        0x0010:  0000 0000 0000 0000 0000 0000 0000 0000  ................
        0x0020:  0000 ffff ffff 0000 0000 1300 0000       ..............
12:56:33.296384 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
12:56:33.303222 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
[..]
13:00:44.340062 00:00:00:00:00:00 > 5f:00:00:00:00:00 null I (s=0,r=0,C) len=42
13:00:44.672350 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
13:00:44.868724 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
13:00:45.340123 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
13:00:46.340173 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
13:00:46.688433 IP truncated-ip - 1454 bytes missing! 192.168.65.66.40313 > 192.168.65.65.5001: . 1426488980:1426490428(1448) ack 1790562292 win 1460 <nop,nop,timestamp[|tcp]>
13:00:48.704431 00:00:21:00:00:00 > 00:00:00:00:00:00 null I (s=17,r=18,C) len=42
13:00:48.886426 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
13:00:50.720463 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
13:00:52.736496 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
13:00:54.752522 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
13:00:54.927556 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
13:00:54.934394 00:00:00:00:00:00 > 00:00:00:00:00:00 null I (s=0,r=0,C) len=42
-->8--
On a different host connected to the same switch, traffic looks more like:
--8<--
2:01:49.388992 IP 192.168.64.1.ntp > 255.255.255.255.ntp: NTPv3, Broadcast, length 48
12:01:50.176550 802.1d config 8000.00:a0:d1:e1:b4:78.8026 root 8000.00:a0:d1:e1:b4:78 pathcost 0 age 0 max 20 hello 2 fdelay 15
12:01:51.235034 arp reply 192.168.64.32 is-at 00:0a:49:00:5e:8a
12:01:51.241857 arp reply 192.168.64.33 is-at 00:0a:49:00:5e:8b
12:01:51.891193 00:00:01:02:c8:58 > 45:c0:00:1c:00:20, ethertype Unknown (0xe000), length 60:
        0x0000:  0001 1164 ee9b 0000 0000 0000 0000 0000  ...d............
        0x0010:  0000 0000 0000 0000 0000 0000 2f6b 8c87  ............/k..
        0x0020:  0000 0000 0000 0000 0000 0000 0000       ..............
12:01:52.192552 802.1d config 8000.00:a0:d1:e1:b4:78.8026 root 8000.00:a0:d1:e1:b4:78 pathcost 0 age 0 max 20 hello 2 fdelay 15
12:01:52.801392 arp reply 192.168.64.34 is-at 00:0a:49:00:5e:8c
12:01:52.808240 arp reply 192.168.64.35 is-at 00:0a:49:00:5e:8d
12:01:54.208495 802.1d config 8000.00:a0:d1:e1:b4:78.8026 root 8000.00:a0:d1:e1:b4:78 pathcost 0 age 0 max 20 hello 2 fdelay 15
12:01:56.224453 802.1d config 8000.00:a0:d1:e1:b4:78.8026 root 8000.00:a0:d1:e1:b4:78 pathcost 0 age 0 max 20 hello 2 fdelay 15
12:01:58.240464 802.1d config 8000.00:a0:d1:e1:b4:78.8026 root 8000.00:a0:d1:e1:b4:78 pathcost 0 age 0 max 20 hello 2 fdelay 15
12:02:00.029320 arp reply 192.168.64.39 is-at 00:0a:49:00:5e:ff
12:02:00.256420 802.1d config 8000.00:a0:d1:e1:b4:78.8026 root 8000.00:a0:d1:e1:b4:78 pathcost 0 age 0 max 20 hello 2 fdelay 15
-->8--

I noticed that the interrupt count is very low too (the interrupt count
as shown in /proc/interrupts is much higher):
--8<--
[root@penguin1 ~]# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:A0:D1:E1:F2:D8
          inet addr:192.168.65.65  Bcast:192.168.65.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:4559786 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4071967 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:4680823977 (4.3 GiB)  TX bytes:4332319475 (4.0 GiB)
          Interrupt:169

eth1      Link encap:Ethernet  HWaddr 00:A0:D1:E1:F2:D9
          inet addr:192.168.64.199  Bcast:192.168.64.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2193 errors:0 dropped:0 overruns:0 frame:0
          TX packets:29 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:180137 (175.9 KiB)  TX bytes:1856 (1.8 KiB)
          Interrupt:169
-->8--

I then tried 2.6.17-rc2-git6. At first it looked OK, the second ethernet 
device was configured properly and I got some traffic through. Once 
I started copying large files (some 5GB were successfully copied) over 
NFS using a (very) fast NFS server though, traffic received by eth1 got
corrupted again:

--8<--
 [root@penguin1 ~]# tcpdump -n -i eth1 -s 0
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 65535 bytes
14:23:14.049450 arp who-has 192.168.64.199 tell 192.168.64.202
14:23:14.049519 arp reply 192.168.64.199 is-at 00:a0:d1:e1:f2:d9
14:23:14.745075 arp who-has 192.168.64.199 tell 192.168.64.202
14:23:14.745082 arp reply 192.168.64.199 is-at 00:a0:d1:e1:f2:d9
14:23:14.852108 IP truncated-ip - 1454 bytes missing! 192.168.64.110.nfs > 192.168.64.199.1021: . 159991419:159992879(1460) ack 3444328765 win 64240
14:23:14.944489 00:00:00:00:00:00 > a3:00:00:00:50:04, ethertype Unknown (0x210d), length 98:
        0x0000:  0000 6175 6469 7428 3131 3436 3030 3030  ..audit(11460000
        0x0010:  3032 2e31 3836 3a36 3329 3a20 7573 6572  02.186:63):.user
        0x0020:  2070 6964 3d33 3336 3120 7569 643d 3020  .pid=3361.uid=0.
        0x0030:  6175 6964 3d34 3239 3439 3637 3239 3520  auid=4294967295.
        0x0040:  6d73 673d 2750 414d 2073 6574 6372 6564  msg='PAM.setcred
        0x0050:  3a20 7573                                :.us
14:23:15.944703 arp who-has 192.168.64.253 tell 192.168.79.254
14:23:16.868291 arp who-has 192.168.64.199 tell 192.168.64.202
14:23:16.868301 arp reply 192.168.64.199 is-at 00:a0:d1:e1:f2:d9
14:23:16.944907 IP truncated-ip - 12 bytes missing! 192.168.64.101.netbios-ns > 192.168.64.255.netbios-ns: NBT UDP PACKET(137): REGISTRATION; REQUEST; BROADCAST
14:23:17.945113 IP truncated-ip - 12 bytes missing! 192.168.64.101.netbios-ns > 192.168.64.255.netbios-ns: NBT UDP PACKET(137): REGISTRATION; REQUEST; BROADCAST
14:23:18.884430 arp who-has 192.168.64.199 tell 192.168.64.202
14:23:18.884441 arp reply 192.168.64.199 is-at 00:a0:d1:e1:f2:d9
14:23:18.945318 IP truncated-ip - 12 bytes missing! 192.168.64.101.netbios-ns > 192.168.64.255.netbios-ns: NBT UDP PACKET(137): REGISTRATION; REQUEST; BROADCAST
-->8--

The ".audit ... PAM.sedcred" string is interesting. This is most likely 
not traffic from the net, but a text inside the host's RAM. Did some 
pointer get mangled?
 
I recompiled the kernel, now with RHFC4's gcc32. The result is similiar
(only after some data was copied using NFS, the second interface goes
bad):
--8<--
[root@penguin1 ~]# tcpdump -n -s 0 -i eth1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 65535 bytes
15:48:02.306927 IP 192.168.64.202 > 192.168.64.199: icmp 64: echo request seq 8801
15:48:02.316088 arp who-has 192.168.64.202 tell 192.168.64.199
15:48:02.316329 arp who-has 192.168.64.199 tell 192.168.79.254
15:48:02.316335 arp reply 192.168.64.199 is-at 00:a0:d1:e1:f2:d9
15:48:02.316338 802.1d config 8000.00:a0:d1:e1:b4:78.8025 root 8000.00:a0:d1:e1:b4:78 pathcost 0 age 0 max 20 hello 2 fdelay 15
15:48:03.307095 IP 192.168.64.202 > 192.168.64.199: icmp 64: echo request seq 8802
15:48:03.307289 IP truncated-ip - 38 bytes missing! 192.168.64.202 > 192.168.64.199: icmp 64: echo request seq 8803
15:48:03.316166 arp who-has 192.168.64.202 tell 192.168.64.199
15:48:03.316397 arp who-has 192.168.64.199 tell 192.168.79.254
15:48:03.316401 arp reply 192.168.64.199 is-at 00:a0:d1:e1:f2:d9
15:48:03.316404 802.1d config 8000.00:a0:d1:e1:b4:78.8025 root 8000.00:a0:d1:e1:b4:78 pathcost 0 age 0 max 20 hello 2 fdelay 15
15:48:03.784698 IP truncated-ip - 38 bytes missing! 192.168.64.202 > 192.168.64.199: icmp 64: echo request seq 8804

12 packets captured
12 packets received by filter
0 packets dropped by kernel
-->8--
No suspect text and no zero filled packets, only truncated ones now,
but that's bad enough to stop NFS and cause bad packet loss:
--8<--
64 bytes from 192.168.64.199: icmp_seq=83 ttl=64 time=147073 ms
64 bytes from 192.168.64.199: icmp_seq=84 ttl=64 time=149073 ms
64 bytes from 192.168.64.199: icmp_seq=85 ttl=64 time=149073 ms
64 bytes from 192.168.64.199: icmp_seq=87 ttl=64 time=149073 ms
64 bytes from 192.168.64.199: icmp_seq=88 ttl=64 time=149073 ms
64 bytes from 192.168.64.199: icmp_seq=233 ttl=64 time=82023 ms
64 bytes from 192.168.64.199: icmp_seq=236 ttl=64 time=80018 ms
64 bytes from 192.168.64.199: icmp_seq=241 ttl=64 time=81018 ms
64 bytes from 192.168.64.199: icmp_seq=243 ttl=64 time=81018 ms
64 bytes from 192.168.64.199: icmp_seq=253 ttl=64 time=85018 ms
64 bytes from 192.168.64.199: icmp_seq=255 ttl=64 time=85018 ms
64 bytes from 192.168.64.199: icmp_seq=256 ttl=64 time=85629 ms
64 bytes from 192.168.64.199: icmp_seq=257 ttl=64 time=87023 ms

--- 192.168.64.199 ping statistics ---
346 packets transmitted, 63 received, +3 errors, 81% packet loss, time 345136ms
rtt min/avg/max/mdev = 80018.748/119940.275/149073.885/21090.211 ms, pipe 151
-->8--

Considering the recent NFS changes, I tried to get the system into this
state using just ttcp. With some determination, three more hosts and 
a few million packets, I succeeded. This time eth0 truncated packets
and traffic slowed to a crawl (~1 good packet every 2s).

Some progress has been made, but it's not quite solid yet.

best regards
	Guenther
