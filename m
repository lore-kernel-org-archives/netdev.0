From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: Add watchdog interrupt
 handler
Date: Sun, 5 Feb 2017 10:31:22 -0800
Message-ID: <82a06d33-b0c4-55bd-43ee-9953db9a559d@gmail.com>
References: <1486240734-13157-1-git-send-email-andrew@lunn.ch>
 <6936eb05-bec7-a898-6dae-875eda888ce1@gmail.com>
 <20170205165259.GB26564@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:36687 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751751AbdBESbY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 13:31:24 -0500
Received: by mail-ot0-f194.google.com with SMTP id 36so8048417otx.3
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 10:31:24 -0800 (PST)
In-Reply-To: <20170205165259.GB26564@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/05/2017 08:52 AM, Andrew Lunn wrote:
>>> +static irqreturn_t mv88e6xxx_g2_watchdog_thread_fn(int irq, void *dev_id)
>>> +{
>>> +	u16 reg;
>>> +
>>> +	struct mv88e6xxx_chip *chip = dev_id;
>>> +
>>> +	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
>>> +
>>> +	dev_info(chip->dev, "Watchdog event: %04x", reg);
>>
>> Should this be 0x%04x just to illustrate the value is hexadecimal? And
> 
> Yes, the prefix would make sense.
> 
>> should this be dev_info_once()?
> 
> Since the next action is to disable the interrupt, and there is no
> code path to reenable it, _once does not seem needed. And if for some
> reason the kernel log is spammed with these messages, i want to
> know. It means my interrupt handling code is badly broken!

Sure, that makes sense then, thanks!
-- 
Florian
