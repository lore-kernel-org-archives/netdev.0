From: Arend van Spriel <arend@broadcom.com>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Sun, 23 Nov 2014 10:43:05 +0100
Message-ID: <5471AC29.6040009@broadcom.com>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <54363ED0.605@broadcom.com> <CACna6rw3XgdJz0uKkAuas8RTzozTdFp2mgF5g1uo7LHJVSMt4g@mail.gmail.com> <3543341.FmUQFH9nrl@eisbaer> <546C5D1F.108@msgid.tls.msk.ru> <546CD94D.9060509@broadcom.com> <546CF66A.3000207@msgid.tls.msk.ru> <546D04EE.1030200@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------040607040605040603000900"
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	=?UTF-8?B?UmFmYcWCIE1pxYJl?= =?UTF-8?B?Y2tp?= <zajec5@gmail.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	brcm80211 development <brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:30194 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753126AbaKWJnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 04:43:09 -0500
In-Reply-To: <546D04EE.1030200@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------040607040605040603000900
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit

On 19-11-14 22:00, Michael Tokarev wrote:
> 19.11.2014 22:58, Michael Tokarev wrote:
>> 19.11.2014 20:54, Arend van Spriel wrote:
> []
>>> I submitted two patches upstream and additionally I have attached two other that are still under review. Could you try these patches and sent me the content of the two debugfs files 'macstat' and 'hardware' after a stall has occurred.
>>
>> You didn't tell which kernel it is based on.  So I tried it on 3.16,
> 
> Ok, I misunderstood you apparently, -- I only tried 2 patches,
> while I should try all 4.  So here it goes.
> 
> The hardware info again:
> 
>> chipnum 0x4313
>> chiprev 0x1
>> chippackage 0x8
>> corerev 0x18
>> boardid 0x1795
>> boardvendor 0x103c
>> boardrev P107
>> boardflags 0x402201
>> boardflags2 0x884
>> ucoderev 0x262032c
>> radiorev 0x1
>> phytype 0x8
>> phyrev 0x1
>> anarev 0xa
>> nvramrev 8
> 
> Macstat:
> 
> txallfrm: 287
> txrtsfrm: 118
> txctsfrm: 25
> txackfrm: 60
> txdnlfrm: 0
> txbcnfrm: 0
> txfunfl[8]: 0 0 0 0 0 0 0 0
> txtplunfl: 0
> txphyerr: 0
> pktengrxducast: 0
> pktengrxdmcast: 0
> rxfrmtoolong: 330
> rxfrmtooshrt: 16
> rxinvmachdr: 722
> rxbadfcs: 4306
> rxbadplcp: 7257
> rxcrsglitch: 61757
> rxstrt: 6667
> rxdfrmucastmbss: 41
> rxmfrmucastmbss: 25
> rxcfrmucast: 116
> rxrtsucast: 0
> rxctsucast: 59
> rxackucast: 19
> rxdfrmocast: 70
> rxmfrmocast: 84
> rxcfrmocast: 211
> rxrtsocast: 3
> rxctsocast: 20
> rxdfrmmcast: 9
> rxmfrmmcast: 1486
> rxcfrmmcast: 0
> rxbeaconmbss: 377
> rxdfrmucastobss: 0
> rxbeaconobss: 1086
> rxrsptmout: 94
> bcntxcancl: 0
> rxf0ovfl: 0
> rxf1ovfl: 0
> rxf2ovfl: 0
> txsfovfl: 0
> pmqovfl: 0
> rxcgprqfrm: 0
> rxcgprsqovfl: 0
> txcgprsfail: 0
> txcgprssuc: 0
> prs_timeout: 0
> rxnack: 0
> frmscons: 0
> txnack: 0
> txglitch_nack: 38
> txburst: 4
> bphy_rxcrsglitch: 2
> phywatchdog: 0
> bphy_badplcp: 0
> 
> 
> As far as I can see, the stats are never updated during stall,
> no numbers are changing, at least while the download is waiting
> for the next packet.  Sometimes wpa_supplicant does something
> little, so some stats gets updated, eg, this is how it looks like
> after about 2..3 minutes:
> 
> txallfrm: 420
> txrtsfrm: 201
> txctsfrm: 25
> txackfrm: 69
> txdnlfrm: 0
> txbcnfrm: 0
> txfunfl[8]: 0 0 0 0 0 0 0 0
> txtplunfl: 0
> txphyerr: 0
> pktengrxducast: 0
> pktengrxdmcast: 0
> rxfrmtoolong: 1908
> rxfrmtooshrt: 73
> rxinvmachdr: 4115
> rxbadfcs: 15064
> rxbadplcp: 42368
> rxcrsglitch: 36620
> rxstrt: 26393
> rxdfrmucastmbss: 48
> rxmfrmucastmbss: 27
> rxcfrmucast: 158
> rxrtsucast: 0
> rxctsucast: 92
> rxackucast: 25
> rxdfrmocast: 113
> rxmfrmocast: 390
> rxcfrmocast: 962
> rxrtsocast: 38
> rxctsocast: 59
> rxdfrmmcast: 48
> rxmfrmmcast: 7681
> rxcfrmmcast: 0
> rxbeaconmbss: 1505
> rxdfrmucastobss: 0
> rxbeaconobss: 6059
> rxrsptmout: 171
> bcntxcancl: 0
> rxf0ovfl: 0
> rxf1ovfl: 0
> rxf2ovfl: 0
> txsfovfl: 0
> pmqovfl: 0
> rxcgprqfrm: 0
> rxcgprsqovfl: 0
> txcgprsfail: 0
> txcgprssuc: 0
> prs_timeout: 0
> rxnack: 0
> frmscons: 0
> txnack: 0
> txglitch_nack: 41
> txburst: 4
> bphy_rxcrsglitch: 5
> phywatchdog: 0
> bphy_badplcp: 0
> 
> 
> This is with 3.18-tobe kernel (current Linus git).
> 
> Dunno if this is helpful or not...

Well, it shows tx looks ok, but with download there is not much of that
going on. At least no large packets. However, I did find some missing
pieces related to bt-coex. Given that you device is a wifi-bt combo card
that is likely an issue for you. One of the missing pieces looks in
sprom for parameters and that is provided by bcma. However, it does not
seem to extract bt-coex related stuff. So I have attached a patch based
on 3.18-rc5 for bcma that dumps the sprom contents. Could you sent that
content to me.

Regards,
Arend

> Thanks,
> 
> /mjt
> 


--------------040607040605040603000900
Content-Type: text/x-patch;
	name="0001-bcma-dump-raw-sprom-content-for-debugging.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-bcma-dump-raw-sprom-content-for-debugging.patch"

>From 29cfa8ec164e2d742f98ddb2c5368b70540f5fab Mon Sep 17 00:00:00 2001
From: Arend van Spriel <arend@broadcom.com>
Date: Sun, 23 Nov 2014 10:26:17 +0100
Subject: [PATCH] bcma: dump raw sprom content for debugging

Signed-off-by: Arend van Spriel <arend@broadcom.com>
---
 drivers/bcma/sprom.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/bcma/sprom.c b/drivers/bcma/sprom.c
index efb037f..0c246a4 100644
--- a/drivers/bcma/sprom.c
+++ b/drivers/bcma/sprom.c
@@ -129,10 +129,16 @@ static u8 bcma_sprom_crc(const u16 *sprom, size_t words)
 	int word;
 	u8 crc = 0xFF;
 
+	pr_debug(KBUILD_MODNAME "sprom:");
 	for (word = 0; word < words - 1; word++) {
+		if ((word % 10) == 0)
+			pr_debug("\n\t");
+		pr_debug("%04X ", sprom[word]);
 		crc = bcma_crc8(crc, sprom[word] & 0x00FF);
 		crc = bcma_crc8(crc, (sprom[word] & 0xFF00) >> 8);
 	}
+	if ((word % 10) == 0)
+		pr_debug("\n");
 	crc = bcma_crc8(crc, sprom[words - 1] & 0x00FF);
 	crc ^= 0xFF;
 
-- 
1.9.1


--------------040607040605040603000900--
