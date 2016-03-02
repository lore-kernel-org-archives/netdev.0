From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V2 04/16] net: fec: reduce interrupts
Date: Wed, 2 Mar 2016 15:32:16 -0700
Message-ID: <56D769F0.9070901@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-5-git-send-email-troy.kisky@boundarydevices.com>
 <VI1PR0401MB18558A7D0A57FA8EDBAD5EABFFBC0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
 <56D710EB.5000201@boundarydevices.com>
 <CAHrpEqQkuH1JQfKFa=S+ZqbnHpR_SdihM3_dJ++nokV1tczM_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Fugang Duan <fugang.duan@nxp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"b38611@freescale.com" <b38611@freescale.com>,
	"fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"laci@boundarydevices.com" <laci@boundarydevices.com>,
	"shawnguo@kernel.org" <shawnguo@kernel.org>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"stillcompiling@gmail.com" <stillcompiling@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"arnd@arndb.de" <arnd@arndb.de>
To: Zhi Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34593 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754659AbcCBWcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 17:32:18 -0500
Received: by mail-pa0-f52.google.com with SMTP id fy10so1949883pac.1
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 14:32:18 -0800 (PST)
In-Reply-To: <CAHrpEqQkuH1JQfKFa=S+ZqbnHpR_SdihM3_dJ++nokV1tczM_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/2016 9:47 AM, Zhi Li wrote:
> On Wed, Mar 2, 2016 at 10:12 AM, Troy Kisky
> <troy.kisky@boundarydevices.com> wrote:
>> On 3/2/2016 8:13 AM, Fugang Duan wrote:
>>> From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Thursday, February 25, 2016 8:37 AM
>>>>
>>>> -    if (fep->ptp_clock)
>>>> +    if ((int_events & FEC_ENET_TS_TIMER) && fep->ptp_clock)
>>>>              fec_ptp_check_pps_event(fep);
>>>> -
>>> This is error in here.  FEC compare timer event is not TS timer.
>>>
>>>
>>
>>
>> So when should fec_ptp_check_pps_event be called ? On every interrupt ?
> 
> Compare event is not showed in EIR register.  Need check TCSR, please
> see below code.
> 
> uint fec_ptp_check_pps_event(struct fec_enet_private *fep)
> {
> xx
>  val = readl(fep->hwp + FEC_TCSR(channel));
>         if (val & FEC_T_TF_MASK) {
> }


So, should FEC_ENET_TS_TIMER be removed from FEC_DEFAULT_IMASK, since
the interrupt routine never checks it ?
