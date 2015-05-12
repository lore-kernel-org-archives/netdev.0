From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/3] net: phy: broken turn-around support
Date: Tue, 12 May 2015 13:56:24 -0700
Message-ID: <555268F8.4030109@gmail.com>
References: <1431442563-10218-1-git-send-email-bert@biot.com> <1431452006-3219-1-git-send-email-f.fainelli@gmail.com> <555265EE.9000009@biot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jogo@openwrt.org
To: Bert Vermeulen <bert@biot.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:36134 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753691AbbELU4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 16:56:45 -0400
Received: by pdea3 with SMTP id a3so26640605pde.3
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 13:56:45 -0700 (PDT)
In-Reply-To: <555265EE.9000009@biot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/15 13:43, Bert Vermeulen wrote:
> On 05/12/2015 07:33 PM, Florian Fainelli wrote:
>> Hi all,
>>
>> This is an attempt at solving the broken turn-around problem in a way that
>> is not specific to the mdio-gpio driver, since it affects different kinds of
>> platforms.
>>
>> We cannot make that localized to PHY device drivers because probing the PHY
>> device which has a broken turn-around can fail as early as in get_phy_id(),
>> therefore we need a bit of help from Device Tree/platform_data.
> 
> That is indeed a better place to put that ignore-ta flag, and the device
> tree support is of course a big improvement over the previous patch as well.
> 
> But it's still too big a hammer to hit the AR8316 problem with, I think.
> Just like the previous patch, this disables checking TA on _all_ reads, but
> I really only need it disabled on the first read.
> 
> Are you saying you've seen other systems with this TA problem? Did those
> have problems after more than just the first read?

Yes, I have a bunch of boards here that use a Broadcom BCM53125 switch
which is known not to release the line during turn-around time, and that
is for all reads. A workaround is to discard the read failure indication
from the MDIO controller, but to selectively do that, I would be keen on
using the patches I just posted.
-- 
Florian
