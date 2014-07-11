From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [Bug 79821] New: ethernet/freescale/gianfar_ethtool.c:1584: possible
 bad expression ?
Date: Fri, 11 Jul 2014 11:54:59 +0300
Message-ID: <53BFA663.30005@freescale.com>
References: <20140710055100.394e6a09@samsung-9>
	<20140710.170610.787241466056112359.davem@davemloft.net>
	<20140710.170704.1439211670228191396.davem@davemloft.net>
 <CAOMZO5BDzOQU62-ibYH6sL+tzMGtjXcYFUtW1YUG9eKpoF=SPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<sebastian.poehn@belden.com>
To: Fabio Estevam <festevam@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0185.outbound.protection.outlook.com ([207.46.163.185]:55019
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751169AbaGKIzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2014 04:55:20 -0400
In-Reply-To: <CAOMZO5BDzOQU62-ibYH6sL+tzMGtjXcYFUtW1YUG9eKpoF=SPw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/11/2014 3:37 AM, Fabio Estevam wrote:
> On Thu, Jul 10, 2014 at 9:07 PM, David Miller <davem@davemloft.net> wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Thu, 10 Jul 2014 17:06:10 -0700 (PDT)
>>
>>> From: Stephen Hemminger <stephen@networkplumber.org>
>>> Date: Thu, 10 Jul 2014 05:51:00 -0700
>>>
>>>> [linux-3.16-rc4/drivers/net/ethernet/freescale/gianfar_ethtool.c:1584]: (style)
>>>> Same expression on both sides of '|'.
>>>>
>>>>      for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].ctrl);
>>>
>>> Probably this is meant to be:
>>>
>>> diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
>>> index 76d7070..f697118 100644
>>> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
>>> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
>>> @@ -1581,7 +1581,7 @@ static int gfar_write_filer_table(struct gfar_private *priv,
>>>                return -EBUSY;
>>>
>>>        /* Fill regular entries */
>>> -     for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].ctrl);
>>> +     for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].prop);
>>>             i++)
>>>                gfar_write_filer(priv, i, tab->fe[i].ctrl, tab->fe[i].prop);
>>>        /* Fill the rest with fall-troughs */
>>>
>>> But only a Gianfar expert can say for sure.
>>>
>>> Sebastian, this is your code, please help us out.
>>
>> Ok, we have a problem, Sebastian's email bounces.
>>
>> Anyone else who knows this chip can help us out?  We don't have a listed
>> maintainer for Gianfar in MAINTAINERS :-/
>
> Adding Claudiu on Cc in case he could help.
>

Hi,

Thanks for the notification, Fabio.
I'm checking the hardware manual, and looks like 0 is a valid value for 
the ctrl field, while the prop can be non-zero.  So very likely the fix 
above is correct.  Not sure why no run-time issues were reported for 
this, either a 0 crtl value is unlikely or the Rx classification feature
implemented in gianfar ethtool is hardly used.
I'll get back with a patch soon, unless someone else beats me to it.

Thanks,
Claudiu
