From: Konstantin Khorenko <khorenko@parallels.com>
Subject: Re: [E1000-devel] [Bugme-new] [Bug 12570] New: Bonding does not	work
 over e1000e.
Date: Tue, 17 Mar 2009 17:25:52 +0300
Message-ID: <49BFB2F0.8090704@parallels.com>
References: <8DD2590731AB5D4C9DBF71A877482A900DCA8695@orsmsx509.amr.corp.intel.com> <EA929A9653AAE14F841771FB1DE5A1365F60321240@rrsmsx501.amr.corp.intel.com> <F169D4F5E1F1974DBFAFABF47F60C10A1C2C9480@orsmsx507.amr.corp.intel.com> <EA929A9653AAE14F841771FB1DE5A1365F60321411@rrsmsx501.amr.corp.intel.com> <13830B75AD5A2F42848F92269B11996F3A0F5952@orsmsx509.amr.corp.intel.com> <498C0E8C.9050309@parallels.com> <13830B75AD5A2F42848F92269B11996F3C5C645A@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080300030308020301080605"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"devel@lists.sourceforge.net" <devel@lists.sourceforge.net>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: "Graham, David" <david.graham@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:36559 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733AbZCQO1B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 10:27:01 -0400
In-Reply-To: <13830B75AD5A2F42848F92269B11996F3C5C645A@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080300030308020301080605
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hello David,

sorry for the huge delay, i'll try to answer your questions below.

On 02/17/2009 10:00 PM, Graham, David wrote:
> To get closer to your environment, I reconfigured my network, and same kernel & built-in driver that you used, but channel failover still works in my tests. Because this is without the recent serdes link patches that I referred to earlier, that means I don't expect them to be significant to the problem.

Unfortunately i don't have a direct access to the problematic node thus this takes so long time.
Yesterday at last the kernel 2.6.29-rc4 + patches SerdesSM.patch, disable_dmaclkgating.patch and RemoveRXSEQ.patch was tested and it works fine for the failback!

[root@hostname ~]# uname -a
Linux hostname 2.6.29-rc4.e1000e.ver1 #1 SMP Tue Feb 10 20:47:26 MSK 2009 x86_64 x86_64 x86_64 GNU/Linux
[root@hostname ~]#

##Took down the icbay5 uplink
[root@hostname ~]# cat /proc/net/bonding/bond1
Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth3
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth2
MII Status: down
Link Failure Count: 1
Permanent HW addr: 00:17:a4:77:00:1c

Slave Interface: eth3
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:17:a4:77:00:1e

##Enable icbay5 uplink
[root@hostname ~]# cat /proc/net/bonding/bond1
Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth3
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth2
MII Status: down
Link Failure Count: 1
Permanent HW addr: 00:17:a4:77:00:1c

Slave Interface: eth3
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:17:a4:77:00:1e

## disable icbay6 (this is still working!!!  It used to die right here.
[root@hostname ~]# cat /proc/net/bonding/bond1
Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth2
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth2
MII Status: up
Link Failure Count: 1
Permanent HW addr: 00:17:a4:77:00:1c

Slave Interface: eth3
MII Status: down
Link Failure Count: 1
Permanent HW addr: 00:17:a4:77:00:1e


> But there are some very significant differences in our setups, and I want to align my configuration closer to yours.
> 1) I am using a different Mezz card, with different EEPROM settings (and so features). Could you please send me "ethtool ethx" and "ethtool -e ethx" settings for the problem interfaces ? I may even spot something incorrect in the programming, but if not, I can probably use all or some of your content to make my card behave more like yours.

i've attached ethtool.info.gz file with the following commands output:
   # ethtool eth2
   # ethtool eth3
   # ethtool -e eth2
   # ethtool -e eth3
   # ethtool -i eth2
   # ethtool -i eth3

> 2) We have different link parters , and disable link in a different way.
> I tried to remove the switch modules as you did, but in my bladeserver system, couldn't. There must be some administrative command to allow the latch to unlock, but I am not familiar with it. I'll keep looking. Do you have the same (failing) result if you take the link partners down administratively from the switch console ?

Yes. The same failure occurs if we admin down the switch from the virtual connect.
But we have to do it for the whole switch.  Virtual Connect doesn't allow us to disable just one single port.

> FYI: here's more info & log that show's how the failover works OK on my system.
>
>       2.6.29-rc1 blade in bladeserver
>       Ping from console
>          |
>       +--------+
>       |  bond0 |  static address
>       ++------++
>        |      |
>    +---+--+  ++-----+
>    | eth2 |  | eth3 |
>    +---+--+  ++-----+
>        |      |        Serdes Backplane
>        |      |
>    +---+--+  ++-----+
>    | 5/4  |  | 6/4  | Bladeserver wwitch module/port
>    +---+--+  ++-----+
>        |      |
>     +--+------+----+
>     |  1GB switch  |  External to bladeserver
>     +-----+--------+
>           |
>     +-----+-------+
>     | ping target |
>     +-------------+

This is the same topology of our set up. We use the HP C7000 server chassis with the Virtual Connect enet-F module.

> 3) I am testing in a different chassis/backplane
> Let's address the simpler differences first, but if we go another round or two without being able to figure this out, and you are prepared to send us one of the systems with the problem for definite root cause analysis, you can contact me off-line from this bz and we'll work the detail.

Well, unfortunately sending the system for reproduction does not seem as an option, but if you need/want something to check, we can arrange a WebEx session. Please, let me know if this is needed.


Conclusions: well, the latest kernel with your patches does work, thank you very much, David!
Now i have to solve my original problem - to make RHEL5-based (2.6.18-x) kernel working.
At the moment RHEL5 kernel is affected by 2 issues:
1) that one which seems to be fixed by updating the testkernel from 2.6.29-r1 up to rc4 + 3 your patches.
2) when we break a link, mii status is still reported as "up" in /proc/net/bonding/bond1.
   (at the same time bonding changes the active slave to the working one correctly).

i understand there were a lot of changes since 2.6.18, but i still want to try not to replace the e1000e driver completely from the latest mainstream kernel, but to backport the set of patches to fix this exact issue.
Could you please help me pointing the patches that are essential to fix this issue (and probably issue 2)) from your point of view?

Thank you very much!

-- 
Best regards,

Konstantin Khorenko,
PVC/OpenVZ developer,
Parallels

--------------080300030308020301080605
Content-Type: application/x-gzip;
 name="ethtool.info.gz"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="ethtool.info.gz"

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
HNjXsnH5Iod2+NamMdePWsCaB75rZUMr62tA7OpGaxmDnNqXqdyYS2oLWPOgHibWPXyrailV
ziK2+6r8WzC0vthy+XO/ug+oUMGGF+8Hym4sF7ANoNL2Yst0GUDHH1ChglGhglGhglGhglGh
glGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGh
glGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGh
glGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGh
glGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGh
glGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGhglGh
glGhglGhglGhglGhglGhglGhglGhgjGhgv0mgzyQUcGKQR7IqGDFqGDFqGDFqGDlK/wHHwmg
ghXqPxD1H4j6D0T9B6L+A1H/gaj/QNR/IOo/EPUfiPoPRP0Hov4DUf+BqP9A1H8g6j8Q9R+I
+g9E/Qei/gO93n/wFEB50FEedJQHHeVBR3nQUR50lAcd5UFHedBRHnSUBx3lQUd50FEedJQH
HeVBR3ngKQ885YGnPPCUB57ywFMeeMoDT3ngKQ885YGnPPCUB57ywFMeeMoDT3kQKA8C5UGg
PAiUB4HyIFAeBMqDQHkQKA8C5UGgPAiUB4HyIFAeBMqDQHkQKQ8i5UGkPIiUB5HyIFIeRMqD
SHkQKQ8i5UGkPIiUB5HyIFIeRMqDSHmQKA8S5UGiPEiUB4nyIFEeJMqDRHmQKA8S5UGiPEiU
B4nyIFEeJMqDRHmQKQ8y5UGmPMiUB5nyIFMeZMqDTHmQKQ8y5UGmPMiUB5nyIFMeZMqDTHnQ
Ux70lAc95UFPedBTHvSUBz3lQU950FMe9JQHPeVBT3nw0n/w9QGUBz3lQU95MFAeDJQHA+XB
QHkwUB4MlAfUf6CB8oD6D0T9B6L+A1H/gaj/QNR/IOo/EPUfiPoPRP0Hov4DUf+BqP9A1H8g
6j8Q9R+I+g9E/Qei/gNR/4Go/0DUfyDqPxD1H4j6D0T9B6L+A1H/gaj/QNR/IOo/EPUfiPoP
RP0Hov4DUf+BqP9A1H8g6j8Q9R+I+g9E/Qei/gNR/4Go/0DUfyDqPxD1H4j6D0T9B6L+A1H/
gaj/QNR/IOo/EPUfiPoPRP0Hov4DUf+BqP9A1H8g6j8Q9R+I+g9E/Qei/gNR/4Go/0DUfyDq
PxD1H4j6D0T9B6L+A1H/gaj/QNR/IOo/EPUfiPoPRP0Hov4DUf+BqP9A1H8g6j8Q9R+I+g9E
/Qei/gNR/4Go/0DUfyDqPxD1H4j6D0T9B6L+A1H/gaj/QNR/IOo/EPMfvHnY7w/fvd0/Hu7H
d5P7/cdv3HR4e9jv79z1bV3trnYPt79ODzduqqaE6aqsP97u72+cfevrf9c/p6v59uHdf40P
0/Xpw/ituut0tXn/eH17P+9L6fJzo3hj9q19/qj+f/+ourr6H7lbUnSlCQEA
--------------080300030308020301080605--
