From: Ben Greear <greearb@candelatech.com>
Subject: Re: /proc/net/dev is funky in 3.3.0
Date: Mon, 02 Apr 2012 22:53:31 -0700
Message-ID: <4F7A905B.3080107@candelatech.com>
References: <4F7A7C98.1030103@candelatech.com> <1333431810.18626.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42465 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559Ab2DCFxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 01:53:34 -0400
In-Reply-To: <1333431810.18626.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/2012 10:43 PM, Eric Dumazet wrote:
> On Mon, 2012-04-02 at 21:29 -0700, Ben Greear wrote:
>> Not all entries are shown!
>>
>> [root@lanner-i7 lanforge]# cat /proc/net/dev|grep sta59
>> [root@lanner-i7 lanforge]# ifconfig sta59
>> sta59     Link encap:Ethernet  HWaddr 00:95:95:00:00:3C
>>             inet addr:10.111.9.39  Bcast:10.111.255.255  Mask:255.255.0.0
>>             inet6 addr: fe80::295:95ff:fe00:3c/64 Scope:Link
>>             UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>             RX packets:58103 errors:0 dropped:0 overruns:0 frame:0
>>             TX packets:26167 errors:0 dropped:0 overruns:0 carrier:0
>>             collisions:0 txqueuelen:1000
>>             RX bytes:39494634 (37.6 MiB)  TX bytes:37095540 (35.3 MiB)
>>
>> Thanks,
>> Ben
>>
>
> Could you post "ip link" result ?
>

It is below.  Looks like /proc/net/dev is missing 6 entries,
sta69 being one of them.  See end of the email for some grep
and |wc results.  Seems easily reproducible, so let me know if
you want more info.

[root@lanner-i7 lanforge]# ip link show dev sta59
466: sta59: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:3c brd ff:ff:ff:ff:ff:ff
[root@lanner-i7 lanforge]# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: p4p1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
     link/ether 00:90:0b:21:9f:5c brd ff:ff:ff:ff:ff:ff
4: p1p1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
     link/ether 00:90:0b:21:9f:5d brd ff:ff:ff:ff:ff:ff
797: sta75: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:4c brd ff:ff:ff:ff:ff:ff
800: sta349: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:32 brd ff:ff:ff:ff:ff:ff
802: sta61: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:3e brd ff:ff:ff:ff:ff:ff
804: sta49: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:32 brd ff:ff:ff:ff:ff:ff
807: sta342: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:2b brd ff:ff:ff:ff:ff:ff
553: sta149: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:10:00:32 brd ff:ff:ff:ff:ff:ff
602: sta300: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:01 brd ff:ff:ff:ff:ff:ff
603: sta301: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:02 brd ff:ff:ff:ff:ff:ff
604: sta302: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:03 brd ff:ff:ff:ff:ff:ff
605: sta303: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:04 brd ff:ff:ff:ff:ff:ff
606: sta304: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:05 brd ff:ff:ff:ff:ff:ff
607: sta305: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:06 brd ff:ff:ff:ff:ff:ff
608: sta306: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:07 brd ff:ff:ff:ff:ff:ff
609: sta307: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:08 brd ff:ff:ff:ff:ff:ff
610: sta308: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:09 brd ff:ff:ff:ff:ff:ff
611: sta309: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:0a brd ff:ff:ff:ff:ff:ff
612: sta310: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:0b brd ff:ff:ff:ff:ff:ff
613: sta311: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:0c brd ff:ff:ff:ff:ff:ff
614: sta312: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:0d brd ff:ff:ff:ff:ff:ff
615: sta313: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:0e brd ff:ff:ff:ff:ff:ff
616: sta314: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:0f brd ff:ff:ff:ff:ff:ff
617: sta315: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:10 brd ff:ff:ff:ff:ff:ff
618: sta316: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:11 brd ff:ff:ff:ff:ff:ff
619: sta317: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:12 brd ff:ff:ff:ff:ff:ff
620: sta318: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:13 brd ff:ff:ff:ff:ff:ff
621: sta319: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:14 brd ff:ff:ff:ff:ff:ff
622: sta320: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:15 brd ff:ff:ff:ff:ff:ff
623: sta321: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:16 brd ff:ff:ff:ff:ff:ff
624: sta322: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:17 brd ff:ff:ff:ff:ff:ff
625: sta323: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:18 brd ff:ff:ff:ff:ff:ff
626: sta324: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:19 brd ff:ff:ff:ff:ff:ff
627: sta325: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:1a brd ff:ff:ff:ff:ff:ff
628: sta326: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:1b brd ff:ff:ff:ff:ff:ff
629: sta327: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:1c brd ff:ff:ff:ff:ff:ff
630: sta328: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:1d brd ff:ff:ff:ff:ff:ff
631: sta329: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:1e brd ff:ff:ff:ff:ff:ff
632: sta330: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:1f brd ff:ff:ff:ff:ff:ff
633: sta331: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:20 brd ff:ff:ff:ff:ff:ff
634: sta332: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:21 brd ff:ff:ff:ff:ff:ff
635: sta333: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:22 brd ff:ff:ff:ff:ff:ff
636: sta334: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:23 brd ff:ff:ff:ff:ff:ff
637: sta335: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:24 brd ff:ff:ff:ff:ff:ff
638: sta336: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:25 brd ff:ff:ff:ff:ff:ff
639: sta337: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:26 brd ff:ff:ff:ff:ff:ff
640: sta338: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:27 brd ff:ff:ff:ff:ff:ff
641: sta339: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:28 brd ff:ff:ff:ff:ff:ff
642: sta340: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:29 brd ff:ff:ff:ff:ff:ff
643: sta341: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:2a brd ff:ff:ff:ff:ff:ff
644: sta343: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:2c brd ff:ff:ff:ff:ff:ff
645: sta344: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:2d brd ff:ff:ff:ff:ff:ff
646: sta345: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:2e brd ff:ff:ff:ff:ff:ff
647: sta346: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:2f brd ff:ff:ff:ff:ff:ff
648: sta347: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:30 brd ff:ff:ff:ff:ff:ff
649: sta348: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:31 brd ff:ff:ff:ff:ff:ff
650: sta350: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:33 brd ff:ff:ff:ff:ff:ff
651: sta351: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:34 brd ff:ff:ff:ff:ff:ff
652: sta352: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:35 brd ff:ff:ff:ff:ff:ff
653: sta353: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:36 brd ff:ff:ff:ff:ff:ff
654: sta354: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:37 brd ff:ff:ff:ff:ff:ff
655: sta355: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:38 brd ff:ff:ff:ff:ff:ff
656: sta356: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:39 brd ff:ff:ff:ff:ff:ff
657: sta357: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:3a brd ff:ff:ff:ff:ff:ff
658: sta358: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:3b brd ff:ff:ff:ff:ff:ff
659: sta359: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:3c brd ff:ff:ff:ff:ff:ff
660: sta360: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:3d brd ff:ff:ff:ff:ff:ff
661: sta361: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:3e brd ff:ff:ff:ff:ff:ff
662: sta362: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:3f brd ff:ff:ff:ff:ff:ff
406: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:0e:8e:3d:30:e8 brd ff:ff:ff:ff:ff:ff
663: sta363: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:40 brd ff:ff:ff:ff:ff:ff
407: wlan1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:0e:8e:3d:30:f8 brd ff:ff:ff:ff:ff:ff
664: sta364: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:41 brd ff:ff:ff:ff:ff:ff
408: sta0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:01 brd ff:ff:ff:ff:ff:ff
665: sta365: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:42 brd ff:ff:ff:ff:ff:ff
409: sta1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:02 brd ff:ff:ff:ff:ff:ff
666: sta366: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:43 brd ff:ff:ff:ff:ff:ff
410: sta2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:03 brd ff:ff:ff:ff:ff:ff
667: sta367: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:44 brd ff:ff:ff:ff:ff:ff
411: sta3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:04 brd ff:ff:ff:ff:ff:ff
668: sta368: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:45 brd ff:ff:ff:ff:ff:ff
412: sta4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:05 brd ff:ff:ff:ff:ff:ff
669: sta369: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:46 brd ff:ff:ff:ff:ff:ff
413: sta5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:06 brd ff:ff:ff:ff:ff:ff
670: sta370: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:47 brd ff:ff:ff:ff:ff:ff
414: sta6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:07 brd ff:ff:ff:ff:ff:ff
671: sta371: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:48 brd ff:ff:ff:ff:ff:ff
415: sta7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:08 brd ff:ff:ff:ff:ff:ff
672: sta372: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:49 brd ff:ff:ff:ff:ff:ff
416: sta8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:09 brd ff:ff:ff:ff:ff:ff
673: sta373: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:4a brd ff:ff:ff:ff:ff:ff
417: sta9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:0a brd ff:ff:ff:ff:ff:ff
674: sta374: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:4b brd ff:ff:ff:ff:ff:ff
418: sta10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:0b brd ff:ff:ff:ff:ff:ff
675: sta375: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:4c brd ff:ff:ff:ff:ff:ff
419: sta11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:0c brd ff:ff:ff:ff:ff:ff
676: sta376: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:4d brd ff:ff:ff:ff:ff:ff
420: sta12: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:0d brd ff:ff:ff:ff:ff:ff
677: sta377: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:4e brd ff:ff:ff:ff:ff:ff
421: sta13: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:0e brd ff:ff:ff:ff:ff:ff
678: sta378: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:4f brd ff:ff:ff:ff:ff:ff
422: sta14: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:0f brd ff:ff:ff:ff:ff:ff
679: sta379: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:50 brd ff:ff:ff:ff:ff:ff
423: sta15: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:10 brd ff:ff:ff:ff:ff:ff
680: sta380: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:51 brd ff:ff:ff:ff:ff:ff
424: sta16: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:11 brd ff:ff:ff:ff:ff:ff
681: sta381: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:52 brd ff:ff:ff:ff:ff:ff
425: sta17: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:12 brd ff:ff:ff:ff:ff:ff
682: sta382: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:53 brd ff:ff:ff:ff:ff:ff
426: sta18: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:13 brd ff:ff:ff:ff:ff:ff
683: sta383: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:54 brd ff:ff:ff:ff:ff:ff
427: sta19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:14 brd ff:ff:ff:ff:ff:ff
684: sta384: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:55 brd ff:ff:ff:ff:ff:ff
428: sta20: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:15 brd ff:ff:ff:ff:ff:ff
685: sta385: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:56 brd ff:ff:ff:ff:ff:ff
429: sta21: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:16 brd ff:ff:ff:ff:ff:ff
686: sta386: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:57 brd ff:ff:ff:ff:ff:ff
430: sta22: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:17 brd ff:ff:ff:ff:ff:ff
687: sta387: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:58 brd ff:ff:ff:ff:ff:ff
431: sta23: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:18 brd ff:ff:ff:ff:ff:ff
688: sta388: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:59 brd ff:ff:ff:ff:ff:ff
432: sta24: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:19 brd ff:ff:ff:ff:ff:ff
689: sta389: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:5a brd ff:ff:ff:ff:ff:ff
433: sta25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:1a brd ff:ff:ff:ff:ff:ff
690: sta390: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:5b brd ff:ff:ff:ff:ff:ff
434: sta26: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:1b brd ff:ff:ff:ff:ff:ff
691: sta391: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:5c brd ff:ff:ff:ff:ff:ff
435: sta27: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:1c brd ff:ff:ff:ff:ff:ff
692: sta392: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:5d brd ff:ff:ff:ff:ff:ff
436: sta28: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:1d brd ff:ff:ff:ff:ff:ff
693: sta393: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:5e brd ff:ff:ff:ff:ff:ff
437: sta29: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:1e brd ff:ff:ff:ff:ff:ff
694: sta394: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:5f brd ff:ff:ff:ff:ff:ff
438: sta30: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:1f brd ff:ff:ff:ff:ff:ff
695: sta395: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:60 brd ff:ff:ff:ff:ff:ff
439: sta31: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:20 brd ff:ff:ff:ff:ff:ff
696: sta396: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:61 brd ff:ff:ff:ff:ff:ff
440: sta32: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:21 brd ff:ff:ff:ff:ff:ff
697: sta397: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:62 brd ff:ff:ff:ff:ff:ff
441: sta33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:22 brd ff:ff:ff:ff:ff:ff
698: sta398: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:63 brd ff:ff:ff:ff:ff:ff
442: sta34: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:23 brd ff:ff:ff:ff:ff:ff
699: sta399: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:30:00:64 brd ff:ff:ff:ff:ff:ff
443: sta35: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:24 brd ff:ff:ff:ff:ff:ff
444: sta36: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:25 brd ff:ff:ff:ff:ff:ff
445: sta37: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:26 brd ff:ff:ff:ff:ff:ff
446: sta38: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:27 brd ff:ff:ff:ff:ff:ff
447: sta39: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:28 brd ff:ff:ff:ff:ff:ff
448: sta40: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:29 brd ff:ff:ff:ff:ff:ff
449: sta41: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:2a brd ff:ff:ff:ff:ff:ff
450: sta42: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:2b brd ff:ff:ff:ff:ff:ff
451: sta43: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:2c brd ff:ff:ff:ff:ff:ff
452: sta44: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:2d brd ff:ff:ff:ff:ff:ff
453: sta45: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:2e brd ff:ff:ff:ff:ff:ff
454: sta46: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:2f brd ff:ff:ff:ff:ff:ff
455: sta47: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:30 brd ff:ff:ff:ff:ff:ff
456: sta48: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:31 brd ff:ff:ff:ff:ff:ff
457: sta50: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:33 brd ff:ff:ff:ff:ff:ff
458: sta51: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:34 brd ff:ff:ff:ff:ff:ff
459: sta52: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:35 brd ff:ff:ff:ff:ff:ff
460: sta53: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:36 brd ff:ff:ff:ff:ff:ff
461: sta54: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:37 brd ff:ff:ff:ff:ff:ff
462: sta55: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:38 brd ff:ff:ff:ff:ff:ff
463: sta56: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:39 brd ff:ff:ff:ff:ff:ff
464: sta57: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:3a brd ff:ff:ff:ff:ff:ff
465: sta58: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:3b brd ff:ff:ff:ff:ff:ff
466: sta59: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:3c brd ff:ff:ff:ff:ff:ff
467: sta60: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:3d brd ff:ff:ff:ff:ff:ff
468: sta62: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:3f brd ff:ff:ff:ff:ff:ff
469: sta63: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:40 brd ff:ff:ff:ff:ff:ff
470: sta64: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:41 brd ff:ff:ff:ff:ff:ff
471: sta65: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:42 brd ff:ff:ff:ff:ff:ff
472: sta66: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:43 brd ff:ff:ff:ff:ff:ff
473: sta67: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:44 brd ff:ff:ff:ff:ff:ff
474: sta68: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:45 brd ff:ff:ff:ff:ff:ff
475: sta69: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:46 brd ff:ff:ff:ff:ff:ff
476: sta70: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:47 brd ff:ff:ff:ff:ff:ff
477: sta71: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:48 brd ff:ff:ff:ff:ff:ff
478: sta72: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:49 brd ff:ff:ff:ff:ff:ff
479: sta73: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:4a brd ff:ff:ff:ff:ff:ff
480: sta74: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:4b brd ff:ff:ff:ff:ff:ff
481: sta76: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:4d brd ff:ff:ff:ff:ff:ff
482: sta77: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:4e brd ff:ff:ff:ff:ff:ff
483: sta78: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:4f brd ff:ff:ff:ff:ff:ff
484: sta79: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:50 brd ff:ff:ff:ff:ff:ff
485: sta80: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:51 brd ff:ff:ff:ff:ff:ff
486: sta81: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:52 brd ff:ff:ff:ff:ff:ff
487: sta82: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:53 brd ff:ff:ff:ff:ff:ff
488: sta83: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:54 brd ff:ff:ff:ff:ff:ff
489: sta84: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:55 brd ff:ff:ff:ff:ff:ff
490: sta85: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:56 brd ff:ff:ff:ff:ff:ff
491: sta86: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:57 brd ff:ff:ff:ff:ff:ff
492: sta87: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:58 brd ff:ff:ff:ff:ff:ff
493: sta88: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:59 brd ff:ff:ff:ff:ff:ff
494: sta89: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:5a brd ff:ff:ff:ff:ff:ff
495: sta90: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:5b brd ff:ff:ff:ff:ff:ff
496: sta91: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:5c brd ff:ff:ff:ff:ff:ff
497: sta92: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:5d brd ff:ff:ff:ff:ff:ff
498: sta93: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:5e brd ff:ff:ff:ff:ff:ff
499: sta94: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:5f brd ff:ff:ff:ff:ff:ff
500: sta95: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:60 brd ff:ff:ff:ff:ff:ff
501: sta96: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:61 brd ff:ff:ff:ff:ff:ff
502: sta97: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:62 brd ff:ff:ff:ff:ff:ff
503: sta98: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:63 brd ff:ff:ff:ff:ff:ff
504: sta99: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:95:95:00:00:64 brd ff:ff:ff:ff:ff:ff
[root@lanner-i7 lanforge]# ip link|grep sta59
466: sta59: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
[root@lanner-i7 lanforge]# cat /proc/net/dev|wc
     202    3420   24979
[root@lanner-i7 lanforge]# cat /proc/net/dev|grep sta59
[root@lanner-i7 lanforge]# ip link show|grep qdisc|wc
     206    2264   17189

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
