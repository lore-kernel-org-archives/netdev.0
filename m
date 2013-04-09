From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH net-next 07/11] tg3: Add support for link flap
 avoidance
Date: Tue, 9 Apr 2013 13:59:08 -0700
Message-ID: <5164811C.2030005@broadcom.com>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
 <1365533291-5672-8-git-send-email-nsujir@broadcom.com>
 <20130409.151540.1097356797775302170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2931 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936020Ab3DIU7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 16:59:21 -0400
In-Reply-To: <20130409.151540.1097356797775302170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/09/2013 12:15 PM, David Miller wrote:
> From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
> Date: Tue, 9 Apr 2013 11:48:07 -0700
>
>> This patch and the following two patches add support for link flap avoidance
>> by maintaining the link on power down. This feature is required for
>> management capable devices to have the management connection
>> uninterrupted on driver reload, reboot and interface up/down.
>>
>> A second NVRAM setting is 1G_ON_VAUX_OK (off by default). This adds
>> support for gigabit link speed when device is on auxiliary power.
>>
>> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
>> Signed-off-by: Michael Chan <mchan@broadcom.com>
>
> Looks good, all applied, thanks.
>
> If we force a PHY reset due to EEE changes, will the ASF traffic
> disruption warning message be emitted?

No, the message is not emitted. There are a couple of reasons for this.

1. The intent of the message is to warn on user initiated operations that cause 
a link flap.

2. The link flap due to EEE mismatch and force reset is possible the very first 
time the system is powered on. It's reasonable to expect the link to be in flux 
till the driver is in sync.


After the 1st time the EEE mismatch can only happen if the user modfies it via 
ethtool. tg3 does not yet support the set_eee ethtool handler. When we implement 
that, we will add the warning there similar to the other ethtool op handlers.


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
