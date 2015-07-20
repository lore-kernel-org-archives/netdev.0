From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/6] net: bcmgenet: PHY initialization rework
Date: Mon, 20 Jul 2015 13:00:55 -0700
Message-ID: <55AD5377.6020401@gmail.com>
References: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com> <BA3C0C60-58CC-4D5F-9FD0-201E29F5542F@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Petri Gynther <pgynther@google.com>
To: Jaedon Shin <jaedon.shin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33810 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162AbbGTUCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 16:02:52 -0400
Received: by pdbbh15 with SMTP id bh15so60914723pdb.1
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 13:02:51 -0700 (PDT)
In-Reply-To: <BA3C0C60-58CC-4D5F-9FD0-201E29F5542F@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/07/15 06:53, Jaedon Shin wrote:
>> On Jul 17, 2015, at 7:51 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>
>> Hi David, Petri, Jaedon,
>>
>> This patch series reworks how we perform PHY initialization and resets in the
>> GENET driver. Although this contains mostly fixes, some of the changes are a
>> bit too intrusive to be backported to 'net' at the moment.
>>
>> Some of the motivations behind these changes were to reduce the time spent in how
>> performing MDIO transactions, since it is better to perform then when we have
>> interrupts enabled. This reduces the bring-up time of GENET from ~600 msecs down
>> to ~8 msecs, and about the same time for suspend/resume.
>>
>> Since I do not currently have a system which is not DT-aware, can you (Petri,
>> Jaedon) give this a try and confirm things keep working as expected?
>>
>> Thanks!
>>
> 
> I tested your patch series on Broadcom 40nm set-top box platform that used
> internal phy. I did not have the exact measurements. but I expect it to improve
> on the interface-up or link-up time. and I compared the changes roughly from
> kernel print time. please see below.

Thanks for testing! The patches are not really meant to improve the link
up/down time, the fact that you are seeing an improvement here is
coincidental and/or not related. The patches are meant to provide an
improvement during system resume (out of S2 and S3) and during the
initial probe of the driver.

Sounds like you tested this with a DT-enabled MIPS platform, do you have
code handy to do the same experiement without DT?

> 
> - before patching
> [    1.865126] bcmgenet 10430000.ethernet eth0: Link is Down
> [    3.941132] bcmgenet 10430000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
> 
> - after patching
> [    3.145127] bcmgenet 10430000.ethernet eth0: Link is Down
> [    4.189140] bcmgenet 10430000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
> 
>> Florian Fainelli (6):
>>  net: bcmgenet: Remove excessive PHY reset
>>  net: bcmgenet: Use correct dev_id for free_irq
>>  net: bcmgenet: Power on integrated GPHY in bcmgenet_power_up()
>>  net: bcmgenet: Determine PHY type before scanning MDIO bus
>>  net: bcmgenet: Delay PHY initialization to bcmgenet_open()
>>  net: bcmgenet: Remove init parameter from bcmgenet_mii_config
>>
>> drivers/net/ethernet/broadcom/genet/bcmgenet.c | 33 +++++-----
>> drivers/net/ethernet/broadcom/genet/bcmgenet.h |  5 +-
>> drivers/net/ethernet/broadcom/genet/bcmmii.c   | 84 ++++++++++++--------------
>> 3 files changed, 59 insertions(+), 63 deletions(-)
>>
>> -- 
>> 2.1.0
>>
> 


-- 
Florian
