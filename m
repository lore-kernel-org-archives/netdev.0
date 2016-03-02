From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH 2/4] net: can: ifi: Fix TX DLC configuration
Date: Wed, 02 Mar 2016 11:37:18 +0100
Message-ID: <56D6C25E.4000407@denx.de>
References: <1456775971-4946-1-git-send-email-marex@denx.de> <1456775971-4946-3-git-send-email-marex@denx.de> <56D5DB54.6000600@hartkopp.net> <56D60938.6060903@denx.de> <56D6846A.9020808@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:42930 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbcCBKh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 05:37:58 -0500
In-Reply-To: <56D6846A.9020808@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2016 07:12 AM, Oliver Hartkopp wrote:
> 
> 
> On 03/01/2016 10:27 PM, Marek Vasut wrote:
>> On 03/01/2016 07:11 PM, Oliver Hartkopp wrote:
>>
>> Hi!
>>
>>> On 02/29/2016 08:59 PM, Marek Vasut wrote:
>>>> The TX DLC, the transmission length information, was not written
>>>> into the transmit configuration register. When using the CAN core
>>>> with different CAN controller, the receiving CAN controller will
>>>> receive only the ID part of the CAN frame, but no data at all.
>>>>
>>>> This patch adds the TX DLC into the register to fix this issue.
>>>>
>>>> Signed-off-by: Marek Vasut <marex@denx.de>
>>>> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
>>>> Cc: Mark Rutland <mark.rutland@arm.com>
>>>> Cc: Oliver Hartkopp <socketcan@hartkopp.net>
>>>> Cc: Wolfgang Grandegger <wg@grandegger.com>
>>>> ---
>>>>  drivers/net/can/ifi_canfd/ifi_canfd.c | 5 +++++
>>>>  1 file changed, 5 insertions(+)
>>>>
>>>> diff --git a/drivers/net/can/ifi_canfd/ifi_canfd.c b/drivers/net/can/ifi_canfd/ifi_canfd.c
>>>> index 72f5205..82a33bd 100644
>>>> --- a/drivers/net/can/ifi_canfd/ifi_canfd.c
>>>> +++ b/drivers/net/can/ifi_canfd/ifi_canfd.c
>>>> @@ -774,10 +774,15 @@ static netdev_tx_t ifi_canfd_start_xmit(struct sk_buff *skb,
>>>>  
>>>>  	if (priv->can.ctrlmode & (CAN_CTRLMODE_FD | CAN_CTRLMODE_FD_NON_ISO)) {
>>>>  		if (can_is_canfd_skb(skb)) {
>>>> +			txdlc |= can_len2dlc(cf->len);
>>>>  			txdlc |= IFI_CANFD_TXFIFO_DLC_EDL;
>>>>  			if (cf->flags & CANFD_BRS)
>>>>  				txdlc |= IFI_CANFD_TXFIFO_DLC_BRS;
>>>> +		} else {
>>>> +			txdlc |= cf->len;
>>>>  		}
>>>> +	} else {
>>>> +		txdlc |= cf->len;
>>>>  	}
>>>
>>> Please use
>>>
>>> 	txdlc |= can_len2dlc(cf->len);
>>>
>>> by default (it works for CAN and CAN FD).
>>>
>>> So that it looks more like:
>>>
>>> 	txdlc |= can_len2dlc(cf->len);
>>
>> Roger.
>>
>>> 	if ((priv->can.ctrlmode & CAN_CTRLMODE_FD) && can_is_canfd_skb(skb)) {
>>> 		txdlc |= IFI_CANFD_TXFIFO_DLC_EDL;
>>> 		if (cf->flags & CANFD_BRS)
>>> 			txdlc |= IFI_CANFD_TXFIFO_DLC_BRS;
>>> 	}
>>>
>>> Testing against CAN_CTRLMODE_FD_NON_ISO is wrong!
>>> This configuration bit is just for the protocol on the wire and is no
>>> distinction for CAN / CAN FD.
>>
>> So CAN_CTRLMODE_FD is always set if the system operates in CAN/FD mode.
> 
> Not the 'system' but this specific CAN netdevice.

Ooops, of course, sorry.

>> And in addition to that, if the system operates in CAN/FD BOSCH mode,
>> the CAN_CTRLMODE_FD_NON_ISO is set. Do I understand it correctly ?
> 
> Yep! ('the CAN netdev')

Thanks for the clarification!

-- 
Best regards,
Marek Vasut
