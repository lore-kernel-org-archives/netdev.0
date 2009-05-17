From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: bond + tc regression ?
Date: Sun, 17 May 2009 21:46:41 +0300
Message-ID: <1242586001.2711.11.camel@hazard2.francoudi.com>
References: <1241538358.27647.9.camel@hazard2.francoudi.com>
	 <200905090005.38712.denys@visp.net.lb>
	 <20090508220727.GA26865@francoudi.com>
	 <200905090142.47250.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hdOcPiIS4brmdHICqXAX"
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:2293 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbZEQSqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 14:46:45 -0400
In-Reply-To: <200905090142.47250.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hdOcPiIS4brmdHICqXAX
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


> > All child classes have smaller bursts than the parent. However, there are
> > two sub-classes which have ceil at 70% of parent, e.g. ~500mbit each. I
> > don't know HTB internals, perhaps these two classes make the parent class
> > overstretch itself.
> As i remember important to keep sum of child rates lower or equal parent rate.
> Sure ceil of childs must not exceed ceil of parent.
> Sometimes i had mess, when i tried to play with quantum value. After all that 
> i switched to HFSC which works for me flawlessly. Maybe we should give more 
> attention to HTB problem with high speeds and help kernel developers spot 
> problem, if there is any.

In case of HFSC my problem is even worse. With 775mbit ceiling
configured it is passing over 900mbit in reality. Moreover not having
statistics for parent classes makes it difficult to troubleshoot :( I'm
100% sure that it is 900 mbps, I see this on the switch.

Attached is "tc -s -d class show dev bond0" output.

To calculate total traffic rate:

$ cat hfsc-stat.txt | grep rate | grep Kbit | sed 's/Kbit//' | awk
'{ a=a+$2; } END { print a; }'
906955

Did I misconfigure something ?... How can hfsc go above 775mbit when
everything goes via class 1:2 with 775mbit rate & ul ?

> > By the way, I experience the same "overstretching" with hfsc. In any case,
> > I prefer HTB because it reports statistics of parent classes, unlike hfsc.
> Sometimes it happen when some offloading enabled on devices.
> Check ethtool -k device

Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off


> I think everything except rx/tx checksumming have to be off, at least for 
> test.
> 
> Disable them by "ethtool -K device tso off " for example.

Doesn't help.

-- 
Best Regards,
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel PLC, Cyprus - www.prime-tel.com
Tel: +357 25 100100 Fax: +357 2210 2211


--=-hdOcPiIS4brmdHICqXAX
Content-Disposition: attachment; filename=hfsc-stat.txt
Content-Type: text/plain; name=hfsc-stat.txt; charset=UTF-8
Content-Transfer-Encoding: 7bit

class hfsc 1:99 parent 1: leaf 99: sc m1 0bit d 15.0ms m2 542500Kbit 
 Sent 20385133 bytes 192619 pkt (dropped 7070, overlimits 0 requeues 0) 
 rate 402936bit 432pps backlog 0b 0p requeues 0 
 period 192581 work 20385133 bytes rtwork 20353003 bytes level 0 

class hfsc 1:5005 parent 1:97 leaf 5005: sc m1 0bit d 200.0ms m2 6103Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 2948666978 bytes 4359774 pkt (dropped 50623, overlimits 0 requeues 0) 
 rate 55946Kbit 10338pps backlog 0b 7p requeues 0 
 period 1246140 work 2945839727 bytes rtwork 332352472 bytes level 0 

class hfsc 1:98 parent 1:2 leaf 98: sc m1 0bit d 500.0ms m2 43400Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 4644738789 bytes 5853965 pkt (dropped 165294, overlimits 0 requeues 0) 
 rate 85749Kbit 13526pps backlog 0b 0p requeues 0 
 period 1968169 work 4633993957 bytes rtwork 2322556251 bytes level 0 

class hfsc 1:100 parent 1:2 sc m1 0bit d 5.0ms m2 15000Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 period 290192 work 76779316 bytes level 1 

class hfsc 1:10 parent 1:2 sc m1 0bit d 1.0ms m2 542500Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 period 464809 work 877481554 bytes level 1 

class hfsc 1:5004 parent 1:97 leaf 5004: sc m1 0bit d 200.0ms m2 6103Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 3181480387 bytes 4586738 pkt (dropped 50789, overlimits 0 requeues 0) 
 rate 60049Kbit 10765pps backlog 0b 9p requeues 0 
 period 1258266 work 3178564479 bytes rtwork 332600104 bytes level 0 

class hfsc 1:5006 parent 1:97 leaf 5006: sc m1 0bit d 200.0ms m2 6103Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 842333834 bytes 1339029 pkt (dropped 9194, overlimits 0 requeues 0) 
 rate 18154Kbit 3349pps backlog 0b 2p requeues 0 
 period 806244 work 841676259 bytes rtwork 332340905 bytes level 0 

class hfsc 1:3e9 parent 1:200 leaf 3e9: sc m1 0bit d 0us m2 256000bit ul m1 0bit d 0us m2 100000Kbit 
 Sent 23292 bytes 308 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 488bit 1pps backlog 0b 0p requeues 0 
 period 298 work 23292 bytes rtwork 21371 bytes level 0 

class hfsc 1:5001 parent 1:97 leaf 5001: sc m1 0bit d 200.0ms m2 6103Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 2541073789 bytes 3768515 pkt (dropped 39084, overlimits 0 requeues 0) 
 rate 52514Kbit 9201pps backlog 0b 4p requeues 0 
 period 1221187 work 2538919598 bytes rtwork 332543703 bytes level 0 

class hfsc 1:3e8 parent 1:200 leaf 3e8: sc m1 0bit d 0us m2 512000bit ul m1 0bit d 0us m2 100000Kbit 
 Sent 2140 bytes 34 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 32bit 0pps backlog 0b 0p requeues 0 
 period 34 work 2140 bytes rtwork 2140 bytes level 0 

class hfsc 1:3eb parent 1:300 leaf 3eb: sc m1 0bit d 0us m2 64000bit ul m1 0bit d 0us m2 100000Kbit 
 Sent 206 bytes 3 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 period 3 work 206 bytes rtwork 206 bytes level 0 

class hfsc 1:5003 parent 1:97 leaf 5003: sc m1 0bit d 200.0ms m2 6103Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 2245687618 bytes 3498522 pkt (dropped 35135, overlimits 0 requeues 0) 
 rate 42763Kbit 8415pps backlog 0b 5p requeues 0 
 period 1192583 work 2244028709 bytes rtwork 332304111 bytes level 0 

class hfsc 1:3ea parent 1:300 leaf 3ea: sc m1 0bit d 0us m2 1024Kbit ul m1 0bit d 0us m2 100000Kbit 
 Sent 54214 bytes 442 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 16bit 0pps backlog 0b 0p requeues 0 
 period 413 work 54214 bytes rtwork 48427 bytes level 0 

class hfsc 1:5002 parent 1:97 leaf 5002: sc m1 0bit d 200.0ms m2 6103Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 2915382517 bytes 4002191 pkt (dropped 35677, overlimits 0 requeues 0) 
 rate 54029Kbit 9447pps backlog 0b 7p requeues 0 
 period 1219564 work 2912952580 bytes rtwork 332338435 bytes level 0 

class hfsc 1:97 parent 1:2 sc m1 0bit d 200.0ms m2 97650Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 period 1853176 work 14661981352 bytes level 1 

class hfsc 1: root 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 period 0 level 3 

class hfsc 1:4004 parent 1:79 leaf 4004: sc m1 0bit d 50.0ms m2 25090Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 4401715817 bytes 4690294 pkt (dropped 32975, overlimits 0 requeues 0) 
 rate 84643Kbit 11103pps backlog 0b 0p requeues 0 
 period 3255986 work 4402143323 bytes rtwork 1368797472 bytes level 0 

class hfsc 1:4005 parent 1:79 leaf 4005: sc m1 0bit d 50.0ms m2 25090Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 4858823203 bytes 5510336 pkt (dropped 45336, overlimits 0 requeues 0) 
 rate 90141Kbit 12773pps backlog 0b 0p requeues 0 
 period 3648819 work 4859323215 bytes rtwork 1370067779 bytes level 0 

class hfsc 1:2 parent 1: sc m1 0bit d 0us m2 775000Kbit 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 period 6902 work 48071507639 bytes level 2 

class hfsc 1:4006 parent 1:79 leaf 4006: sc m1 0bit d 50.0ms m2 25090Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 2215296226 bytes 2405111 pkt (dropped 16771, overlimits 0 requeues 0) 
 rate 41477Kbit 5802pps backlog 0b 0p requeues 0 
 period 2036400 work 2217428341 bytes rtwork 1369522295 bytes level 0 

class hfsc 1:c9 parent 1:200 leaf c9: sc m1 0bit d 0us m2 32000bit ul m1 0bit d 0us m2 100000Kbit 
 Sent 240026752 bytes 543130 pkt (dropped 7429, overlimits 0 requeues 0) 
 rate 4201Kbit 1193pps backlog 0b 0p requeues 0 
 period 307816 work 240015088 bytes rtwork 1763247 bytes level 0 

class hfsc 1:4001 parent 1:79 leaf 4001: sc m1 0bit d 50.0ms m2 25090Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 4432353076 bytes 4969719 pkt (dropped 31037, overlimits 0 requeues 0) 
 rate 79306Kbit 10880pps backlog 0b 0p requeues 0 
 period 3452541 work 4431357910 bytes rtwork 1370028629 bytes level 0 

class hfsc 1:4002 parent 1:79 leaf 4002: sc m1 0bit d 50.0ms m2 25090Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 4446019233 bytes 4948736 pkt (dropped 42181, overlimits 0 requeues 0) 
 rate 87046Kbit 11613pps backlog 0b 0p requeues 0 
 period 3427533 work 4448206779 bytes rtwork 1370171471 bytes level 0 

class hfsc 1:4003 parent 1:79 leaf 4003: sc m1 0bit d 50.0ms m2 25090Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 3759018918 bytes 4336293 pkt (dropped 23579, overlimits 0 requeues 0) 
 rate 75258Kbit 10430pps backlog 0b 0p requeues 0 
 period 3147915 work 3758684585 bytes rtwork 1368528984 bytes level 0 

class hfsc 1:80 parent 1:2 leaf 80: sc m1 0bit d 50.0ms m2 1000bit ul m1 0bit d 0us m2 542500Kbit 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 period 0 level 0 

class hfsc 1:b parent 1:10 leaf b: sc m1 0bit d 0us m2 32000bit ul m1 0bit d 0us m2 100000Kbit 
 Sent 878491329 bytes 1005975 pkt (dropped 15849, overlimits 0 requeues 0) 
 rate 14093Kbit 2159pps backlog 0b 0p requeues 0 
 period 464809 work 877481554 bytes rtwork 1891407 bytes level 0 

class hfsc 1:300 parent 1:2 sc m1 0bit d 15.0ms m2 30000Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 period 742649 work 1854498600 bytes level 1 

class hfsc 1:3999 parent 1:79 leaf 3999: sc m1 0bit d 0us m2 1000bit ul m1 0bit d 0us m2 30432Kbit 
 Sent 1617385819 bytes 1260031 pkt (dropped 110848, overlimits 0 requeues 0) 
 rate 30581Kbit 2977pps backlog 0b 56p requeues 0 
 period 1381 work 1609588187 bytes rtwork 58059 bytes level 0 

class hfsc 1:12d parent 1:300 leaf 12d: sc m1 0bit d 0us m2 32000bit ul m1 0bit d 0us m2 100000Kbit 
 Sent 1860128386 bytes 2152291 pkt (dropped 51268, overlimits 0 requeues 0) 
 rate 29842Kbit 4647pps backlog 0b 2p requeues 0 
 period 742499 work 1854444180 bytes rtwork 1775294 bytes level 0 

class hfsc 1:79 parent 1:2 sc m1 0bit d 0us m2 401450Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 period 9008 work 25726746683 bytes level 1 

class hfsc 1:2000 parent 1:79 sc m1 0bit d 0us m2 1000bit ul m1 0bit d 0us m2 401450Kbit 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 period 0 level 0 

class hfsc 1:200 parent 1:2 sc m1 0bit d 10.0ms m2 35000Kbit ul m1 0bit d 0us m2 542500Kbit 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 period 308015 work 240040520 bytes level 1 

class hfsc 1:65 parent 1:100 leaf 65: sc m1 0bit d 0us m2 32000bit ul m1 0bit d 0us m2 100000Kbit 
 Sent 76808971 bytes 457236 pkt (dropped 16755, overlimits 0 requeues 0) 
 rate 1163Kbit 989pps backlog 0b 2p requeues 0 
 period 290193 work 76779316 bytes rtwork 1743830 bytes level 0 

class prio 99:1 parent 99: 
 Sent 1543 bytes 11 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
class prio 99:2 parent 99: 
 Sent 19693553 bytes 185805 pkt (dropped 6999, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
class prio 99:3 parent 99: 
 Sent 690143 bytes 6804 pkt (dropped 71, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
class sfq 3999:1a parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 5942 

class sfq 3999:2d parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 2p requeues 0 
 allot -1279 

class sfq 3999:3e parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 3072 

class sfq 3999:46 parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 2p requeues 0 
 allot -1035 

class sfq 3999:ae parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot -871 

class sfq 3999:c4 parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot 1429 

class sfq 3999:e3 parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot 388 

class sfq 3999:ee parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 2p requeues 0 
 allot -582 

class sfq 3999:155 parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot -1409 

class sfq 3999:17c parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot -128 

class sfq 3999:1c2 parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot 9048 

class sfq 3999:1ca parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 6p requeues 0 
 allot -1156 

class sfq 3999:217 parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 2p requeues 0 
 allot -90 

class sfq 3999:229 parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 336 

class sfq 3999:234 parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 4p requeues 0 
 allot -1248 

class sfq 3999:236 parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 2p requeues 0 
 allot -350 

class sfq 3999:24d parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot 2602 

class sfq 3999:259 parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 2p requeues 0 
 allot 12595 

class sfq 3999:27e parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 15861 

class sfq 3999:28e parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 578 

class sfq 3999:2af parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 6p requeues 0 
 allot -280 

class sfq 3999:32b parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 109 

class sfq 3999:37e parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 6p requeues 0 
 allot -1355 

class sfq 3999:3ed parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 2p requeues 0 
 allot -1080 

class sfq 3999:400 parent 3999: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot -293 

class sfq 98:9 parent 98: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 7590 

class sfq 98:88 parent 98: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 10598 

class sfq 98:10c parent 98: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 16677 

class sfq 98:111 parent 98: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 9084 

class sfq 98:22f parent 98: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 3028 

class sfq 98:294 parent 98: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 12054 

class sfq 98:2f9 parent 98: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 23634 

class sfq 98:322 parent 98: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot -28605 

class sfq 98:364 parent 98: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 6056 

class sfq 98:3b3 parent 98: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 4546 

class sfq 98:3f9 parent 98: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 30100 

class sfq 5001:39a parent 5001: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 24540 

class sfq 4002:226 parent 4002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 4542 

class sfq 5002:49 parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 9084 

class sfq 5002:a7 parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 9084 

class sfq 5002:138 parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 7570 

class sfq 5002:167 parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 4542 

class sfq 5002:19c parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 10606 

class sfq 5002:20b parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot 2974 

class sfq 5002:22a parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 12112 

class sfq 5002:256 parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 25094 

class sfq 5002:289 parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 9084 

class sfq 5002:2f4 parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 3028 

class sfq 5002:341 parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 7570 

class sfq 5002:351 parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 8974 

class sfq 5002:376 parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 6056 

class sfq 5002:3a6 parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 3028 

class sfq 5002:3bc parent 5002: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 6064 

class sfq 5003:68 parent 5003: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 2p requeues 0 
 allot 4542 

class sfq 5003:a7 parent 5003: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot -24050 

class sfq 5003:14d parent 5003: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 2056 

class sfq 5003:1f3 parent 5003: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 6056 

class sfq 5003:27f parent 5003: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 3036 

class sfq 5003:2e8 parent 5003: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 28716 

class sfq 5003:311 parent 5003: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 13572 

class sfq 5003:31a parent 5003: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 13626 

class sfq 5003:361 parent 5003: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 3048 

class sfq 5004:1e parent 5004: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 10932 

class sfq 5004:101 parent 5004: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 4542 

class sfq 5004:12e parent 5004: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 9084 

class sfq 5004:156 parent 5004: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 19526 

class sfq 5004:179 parent 5004: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 671163409p requeues 0 
 allot 724 

class sfq 5004:1a0 parent 5004: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 19682 

class sfq 5004:34c parent 5004: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot -30965 

class sfq 4005:134 parent 4005: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 1514 

class sfq 12d:47 parent 12d: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 4542 

class sfq 12d:a8 parent 12d: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot 1514 

class sfq 12d:ef parent 12d: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 1514 

class sfq 12d:368 parent 12d: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 3268 

class sfq 65:4e parent 65: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 2p requeues 0 
 allot 1514 

class sfq 65:91 parent 65: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 1514 

class sfq 65:286 parent 65: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 10530 

class sfq c9:357 parent c9: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 1514 

class sfq b:72 parent b: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 1514 

class sfq b:1ab parent b: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 13560 

class sfq b:20b parent b: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 13572 

class sfq b:38e parent b: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 1514 


--=-hdOcPiIS4brmdHICqXAX--

