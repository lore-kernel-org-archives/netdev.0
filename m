From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: tg3: regression of netdev stats
Date: Sat, 02 Mar 2013 15:20:11 +0900
Message-ID: <87txouwcf8.fsf@devron.myhome.or.jp>
References: <878v67xnkr.fsf@devron.myhome.or.jp>
	<1362152836.6212.27.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<87y5e6wcv1.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nsujir@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.parknet.co.jp ([210.171.160.6]:42423 "EHLO
	mail.parknet.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab3CBGUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Mar 2013 01:20:14 -0500
In-Reply-To: <87y5e6wcv1.fsf@devron.myhome.or.jp> (OGAWA Hirofumi's message of
	"Sat, 02 Mar 2013 15:10:42 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> writes:

> "Michael Chan" <mchan@broadcom.com> writes:
>
>> On Fri, 2013-03-01 at 22:21 +0900, OGAWA Hirofumi wrote: 
>>> Hi,
>>> 
>>> f4a46d1f46a8fece34edd2023e054072b02e110d (tg3: Prevent spurious tx
>>> timeout by setting carrier off before tx disable.) seems to add the bug.
>>> 
>>> On 3.8.1 (I didn't use 3.7.x series), "ifconfig" commands doesn't show
>>> any stats, i.e. all stats are zero.
>>
>> No stats on an active device transmitting and receiving packets?  I
>> don't seem to see the same problem, but we'll look into this further.
>> Thanks.
>
> Yes, /proc/net/dev didn't show any packet traffic stats (always
> zero). But, e.g. ping/nfs itself works fine.
>
> BTW, chip is
>
> 02:00.0 Ethernet controller [0200]: Broadcom Corporation NetLink BCM57788 Gigabit Ethernet PCIe [14e4:1691] (rev 01)
>
> tg3 0000:02:00.0 eth0: Tigon3 [partno(BCM57788) rev 57780001] (PCI Express) MAC address d4:be:d9:a6:a3:3b
> tg3 0000:02:00.0 eth0: attached PHY driver [Broadcom BCM57780] (mii_bus:phy_addr=200:01)

With some read, this chip seems to be using PHYLIB, and PHYLIB modify
carrier state, so ->link_up confuses with it?

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
