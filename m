From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH net-2.6] can: Fix data length code handling in rx path
Date: Sat, 12 Dec 2009 19:58:33 +0100
Message-ID: <4B23E7D9.1050209@hartkopp.net>
References: <4B23A501.9000208@hartkopp.net> <4B23C602.7050302@grandegger.com> <4B23D4CE.30005@hartkopp.net> <4B23DB9C.8020607@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Barry Song <21cnbao@gmail.com>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-fb.rzone.de ([81.169.146.163]:61081 "HELO
	mo-p00-fb.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753366AbZLMCzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 21:55:17 -0500
Received: from mo-p00-ob.rzone.de (mrclete-mo-p00-ob.mail [192.168.63.64])
	by scum-fb-06.store (RZmta 22.5) with ESMTP id P03dd0lBCHN5zL
	for <netdev@vger.kernel.org>; Sat, 12 Dec 2009 21:11:45 +0100 (MET)
In-Reply-To: <4B23DB9C.8020607@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> Oliver Hartkopp wrote:
>> Wolfgang Grandegger wrote:

>>> Please send you patches inline next time please. For the bfin_can and
>>> the ems_usb driver your patch now masks the dlc with 0xf. Are you sure
>>> this is needed or even correct?
>> Yes. Both needed to be fixed.
>>
>> The bfin_can has an u16 value which is not reduced to 4-bits before.
> 
> The relevant bits are hardware specific.
> 

> 
> I just checked the bfin manual. The DLC value uses a 4 bit field and
> there is also written:
> 
>  "Any DLC value greater than 8 is treated the same as a value of 8."
> 
> That's exactly what this patch fixes. I didn't figure out though, if the
> masking is really required or if the higher bits are undefined (or "0").
> At least it does not harm.

The other 12 bits in the u16 dlc value of the blackfin CAN controller are
'shaded' == marked as 'reserved'. Therefore it's not really specified that
they are always '0' and the masking is indeed needed here.

Tnx for your sign-off.

Regards,
Oliver

