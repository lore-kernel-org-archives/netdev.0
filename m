From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: phy: Ensure the state machine is called when phy is
 UP
Date: Mon, 19 Sep 2016 15:15:38 +0200
Message-ID: <19a526d3-f798-bbb8-328d-9eff18d17eb0@atmel.com>
References: <1460750172-7796-1-git-send-email-alexandre.belloni@free-electrons.com>
 <57114AA4.5080803@gmail.com> <20160415205613.GE25196@piout.net>
 <20160415220508.GC26665@lunn.ch> <20160415221711.GG25196@piout.net>
 <20160415223026.GD26665@lunn.ch> <20160415224559.GH25196@piout.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        <linux-kernel@vger.kernel.org>
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:54203 "EHLO
        eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965355AbcISNPk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 09:15:40 -0400
In-Reply-To: <20160415224559.GH25196@piout.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I come back to this thread to re-start the conversation as I still have
the issue...


Le 16/04/2016 à 00:45, Alexandre Belloni a écrit :
> On 16/04/2016 at 00:30:26 +0200, Andrew Lunn wrote :
>> On Sat, Apr 16, 2016 at 12:17:11AM +0200, Alexandre Belloni wrote:
>>> On 16/04/2016 at 00:05:08 +0200, Andrew Lunn wrote :
>>>>> Trace without my patch:
>>>>> libphy: MACB_mii_bus: probed
>>>>> macb f8020000.ethernet eth0: Cadence GEM rev 0x00020120 at 0xf8020000 irq 27 (fc:c2:3d:0c:6e:05)
>>>>> Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: attached PHY driver [Micrel KSZ8081 or KSZ8091] (mii_bus:phy_addr=f8020000.etherne:01, irq=171)
>>>>> Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change READY -> READY
>>>>> [...]
>>>>> Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change READY -> READY
>>>>
>>>> Are there some state changes before this? How is it getting to state
>>>> READY? It would expect it to start in DOWN, from when the phy device
>>>> was created in phy_device_create().
>>>>
>>>
>>> No other changes. I forgot to mention that this is when booting with a
>>> cable plugged in. Unplugging and replugging the cable makes the link
>>> detection work fine even without the patch.
>>
>> Are you tftpbooting? I.e. has the boot loader already done an auto
>> negotiation?
>>
> 
> Yes.

Yes indeed: this is my use-case: load the kernel from U-Boot using tftp
and having the rootfs in NAND flash so, no NFS rootfs for me.

>> I've looked at the code and i still don't see how it gets to READY.
>> What i do see is that when you connect the phy to the MAC, the
>> interrupt handler is installed. So maybe there are some PHY interrupts
>> before the interface is opened? Could you put a print in
>> phy_interrupt().
>>
> 
> That is indeed the case, and I'm not sure why because
> 99f81afc139c6edd14d77a91ee91685a414a1c66 is trying to disable AN at
> boot.

I don't know what happens to the phy, but this patch does fix the issue
for me:
Tested-by: Nicolas Ferre <nicolas.ferre@atmel.com>

The other alternative that I'm considering seriously as I'm still
struggled with this is to simply remove the phy IRQ from my board DT.

Best regards,
-- 
Nicolas Ferre
