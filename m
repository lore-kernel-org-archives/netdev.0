From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2 net-next 11/13] Documentation: Bindings: Update DT
 binding for separating dsaf dev support
Date: Wed, 27 Apr 2016 10:25:56 -0500
Message-ID: <CAL_JsqLHrHWtiikSt7F39LoExoL2aep5Pqax5cGWWBw-yhz79g@mail.gmail.com>
References: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1461402317-136499-12-git-send-email-Yisen.Zhuang@huawei.com>
 <20160426124847.GA26682@rob-hp-laptop> <57203309.1090501@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	yankejian <yankejian@huawei.com>,
	huangdaode <huangdaode@hisilicon.com>, salil.mehta@huawei.com,
	lipeng321@huawei.com, liguozhu@huawei.com, xieqianqian@huawei.com,
	Wei Xu <xuwei5@hisilicon.com>, Linuxarm <linuxarm@huawei.com>
To: Yisen Zhuang <Yisen.zhuang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:53336 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752977AbcD0P0V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 11:26:21 -0400
In-Reply-To: <57203309.1090501@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2016 at 10:33 PM, Yisen Zhuang <Yisen.zhuang@huawei.com=
> wrote:
> Hi Rob and David,
>
> Please see my comments inline.
>
> David have merged this series to net-next, but we need to modify some=
 codes according
> to Rob's comments. I am not sure if i need to send V3 for this series=
, or separate
> patches of documentation to independent series and generate a new pat=
ch for hns base
> on current net-next?

That's David's call. I'm guessing he wants follow-up patches on top of =
these.

> =E5=9C=A8 2016/4/26 20:48, Rob Herring =E5=86=99=E9=81=93:
>> On Sat, Apr 23, 2016 at 05:05:15PM +0800, Yisen Zhuang wrote:
>>> Because debug dsaf port was separated from service dsaf port, this =
patch
>>> updates the related information of DT binding.
>>
>> Separated when? New version of the h/w? If so, where's the new
>> compatible string? This is quite a big binding change.
>
> There isn't any change of h/w. I separated debug dsaf port from sevic=
e dsaf
> port to make the code more simple and readability.

Okay.

[...]

>>> +  serdes-syscon rather than this address.
>>>    The third region is the PPE register base and size.
>>> -  The fourth region is dsa fabric base register and size.
>>> -  The fifth region is cpld base register and size, it is not requi=
red if do not use cpld.
>>> -- phy-handle: phy handle of physicl port, 0 if not any phy device.=
 see ethernet.txt [1].
>>> +  The fourth region is dsa fabric base register and size. It is no=
t required for
>>> +  single-port mode.
>>> +- reg-names: may be ppe-base and(or) dsaf-base. It is used to find=
 the
>>> +  corresponding reg's index.
>>
>> But you have up to 5 regions.
>>
>> The variable nature of what regions you have tells me you need more
>> specific compatible strings for each chip.
>
> we didn't add support of new h/w. We added these regions to make code=
 simple and readability.
> If we need to add support of next h/w version next time, we don't nee=
d to add many branches
> for these attributes. So we didn't add a new compatible here.

Not sure what you mean by branches. It's fine to put properties for
things that vary among h/w versions, but new compatible strings will
be needed for any new versions.


>>> +- port: subnodes of dsaf. A dsaf node may contain several port nod=
es(Depending
>>> +  on mode of dsaf). Port node contain some attributes listed below=
:
>>> +- port-id: is physical port index in one dsaf.
>>
>> Indexes should generally be avoided. What does the number correspond
>> to in h/w (if anything)?
>
> port-id is index for a port in dsaf, it is correspond to index of PHY=
 showed below.

Okay, you should use reg property here instead.

>
>                                                          CPU
>                                                           |
>                                     ---------------------------------=
--
>                                     |                     |          =
 |
>     ----------------------------------------------    ---------   ---=
------
>     |                         |                  |    |       |   |  =
 |   |
>     |                        PPE                 |    |  PPE  |   |  =
PPE  |
>     |                         |                  |    |   |   |   |  =
 |   |
>     |                         |                  |    |   |   |   |  =
 |   |
>     |                      crossbar              |    |   |   |   |  =
 |   |
>     |                         |                  |    |   |   |   |  =
 |   |
>     |   ----------------------------------       |    |   |   |   |  =
 |   |
>     |   |     |     |      |      |      |       |    |   |   |   |  =
 |   |
>     |   |     |     |      |      |      |       |    |   |   |   |  =
 |   |
>     |  MAC   MAC   MAC    MAC    MAC    MAC      |    |  MAC  |   |  =
MAC  |
>     |   |     |     |      |      |      |       |    |   |   |   |  =
 |   |
>     ----------------------------------------------    ---------   ---=
------
>         |     |     |      |      |      |    \        /  |        / =
 |
>        PHY   PHY   PHY    PHY    PHY    PHY    \      /  PHY      /  =
PHY
>                                                 \    /           /
>                                                  \  /           /
>                                              DSAF(three platform devi=
ce)
>
>>
>>> +- phy-handle: phy handle of physicl port. It is not required if th=
ere isn't

Another typo here.

Rob
