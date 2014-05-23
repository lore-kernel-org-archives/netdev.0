From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] libphy: Add phy specific function to access mmd phy registers
Date: Fri, 23 May 2014 12:18:21 -0700
Message-ID: <CAGVrzcZJ=5ve1RR=rNX3ovm0yUrv+TNWZGeXNh3MOntpt6yyoA@mail.gmail.com>
References: <1400797433-15256-1-git-send-email-vbridgers2013@gmail.com>
 <CAGVrzca9zeqbN_d=KxokKzkeanE8gkYeCGxcQebNd2NSXyHMog@mail.gmail.com> <CAOwfj2PgDAgwUHbSeoH4QkwZzoZd1UmVa+OKdrSJo_qrxRejFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:35326 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbaEWTTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 15:19:02 -0400
Received: by mail-qc0-f175.google.com with SMTP id w7so8740591qcr.6
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 12:19:01 -0700 (PDT)
In-Reply-To: <CAOwfj2PgDAgwUHbSeoH4QkwZzoZd1UmVa+OKdrSJo_qrxRejFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-22 17:02 GMT-07:00 Vince Bridgers <vbridgers2013@gmail.com>:
> Hi Florian,
>
> On Thu, May 22, 2014 at 5:32 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> Hi,
>>
>> 2014-05-22 15:23 GMT-07:00 Vince Bridgers <vbridgers2013@gmail.com>:
>>> libphy was originally written assuming all phy devices support clause 45
>>> access extensions to the mmd registers through the indirection registers
>>> located within the first 16 phy registers. This assumption is not true
>>> in all cases, and one specific example is the Micrel ksz9021 10/100/1000
>>> Mbps phy. Using the stmmac driver, accessing the mmd registers to query
>>> and configure energy efficient Ethernet (EEE) features yielded unexpected
>>> behavior.
>>>
>>> This patch adds mmd access functions to the phy driver that can be
>>> overriden by the phy specific driver if the phy does not support this
>>> mechanism or uses it's own non-standard access mechanism. By default,
>>> the IEEE Compatible clause 45 access mechanism described in clause 22
>>> is used. With this patch, EEE query/configure functions as expected
>>> using the stmmac and the Micrel ksz9021 phy.
>>>
>>> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
>>> ---
>>>  drivers/net/phy/micrel.c     |   15 +++++++++++++
>>>  drivers/net/phy/phy.c        |   49 ++++++++++++++++++++++--------------------
>>>  drivers/net/phy/phy_device.c |    6 ++++++
>>>  include/linux/phy.h          |   10 +++++++++
>>>  4 files changed, 57 insertions(+), 23 deletions(-)
>>
>> Could you split that into at least two patches, one that prepares for
>> allowing drivers to implement their own read/write MMD indirect
>> registers function, and another one that does the real implementation
>> for the Micrel PHY driver?
>>
>
> Yes, I'll take care of that and resubmit.

You might also want to check the Documentation/ entries for the PHY
library and make sure that they get updated with the new function sets
as well.

Thanks!
-- 
Florian
