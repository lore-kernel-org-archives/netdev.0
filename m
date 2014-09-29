From: Zhi Li <lznuaa@gmail.com>
Subject: Re: [PATCH v2 1/1] net: fec: implement rx_copybreak to improve rx performance
Date: Mon, 29 Sep 2014 08:09:59 -0500
Message-ID: <CAHrpEqTL+9iv6SUM7V2Nn4SD4G-20+xAfNCfTqvLMGO0weuj1A@mail.gmail.com>
References: <1411976824-28824-1-git-send-email-b38611@freescale.com>
	<1411992739.30721.23.camel@edumazet-glaptop2.roam.corp.google.com>
	<323020b0c5a44235a1707dd0619deba3@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:38675 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbaI2NKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 09:10:00 -0400
Received: by mail-wg0-f52.google.com with SMTP id n12so11292735wgh.11
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 06:09:59 -0700 (PDT)
In-Reply-To: <323020b0c5a44235a1707dd0619deba3@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014 at 7:43 AM, fugang.duan@freescale.com
<fugang.duan@freescale.com> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com> Sent: Monday, September 29, 2014 8:12 PM
>>To: Duan Fugang-B38611
>>Cc: Li Frank-B20596; davem@davemloft.net; romieu@fr.zoreil.com;
>>netdev@vger.kernel.org; shawn.guo@linaro.org; bhutchings@solarflare.com
>>Subject: Re: [PATCH v2 1/1] net: fec: implement rx_copybreak to improve rx
>>performance
>>
>>On Mon, 2014-09-29 at 15:47 +0800, Fugang Duan wrote:
>>> - Copy short frames and keep the buffers mapped, re-allocate skb instead
>>of
>>>   memory copy for long frames.
>>> - Add support for setting/getting rx_copybreak using generic ethtool
>>> tunable
>>>
>>> Changes V2:
>>> * Implements rx_copybreak
>>
>>>
>>> +#define COPYBREAK_DEFAULT 256
>>> +static unsigned int copybreak __read_mostly = COPYBREAK_DEFAULT;
>>> +module_param(copybreak, uint, 0644); MODULE_PARM_DESC(copybreak,
>>> +             "Maximum packet size that is copied to a new buffer on
>>receive");
>>> +
>>
>>It is not the right way to handle this.
>>
>>Old drivers might still have a legacy module parameter.
>>
>>New implementations should provide the new ethtool support, and only this.
>>No new module parameter is accepted.
>>
>>For details, check following commits :
>>
>>d4ad30b182305ecf97f145a5d4d1fd9e728c6d01 enic: Add tunable_ops support for
>>rx_copybreak
>>
>>f0db9b073415848709dd59a6394969882f517da9 ethtool: Add generic options for
>>tunables
>>
>>
>>Or check the current tree :
>>
>>git grep -n rx_copybreak drivers/net/ethernet/cisco/enic
>>
> The patch implement ethtool interface, pls read the patch completely.

I think Eric's means is that REMOVE module parameter and just keep ethtool API.

best regards
Frank Li

>
> Thanks,
> Andy
