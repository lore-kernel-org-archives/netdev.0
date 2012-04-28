From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCH 23/28] mISDN: Fix compiler warnings
Date: Sat, 28 Apr 2012 12:03:16 +0200
Message-ID: <4F9BC064.4070608@linux-pingi.de>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6EEE@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:59484 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931Ab2D1KHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 06:07:18 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6EEE@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

thanks for the review.

Am 24.04.2012 10:24, schrieb David Laight:
>  
>> diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c 
>> b/drivers/isdn/hardware/mISDN/hfcmulti.c
>> index 884c090..144c35a 100644
>> --- a/drivers/isdn/hardware/mISDN/hfcmulti.c
>> +++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
>> @@ -2456,12 +2456,12 @@ handle_timer_irq(struct hfc_multi *hc)
>>  		spin_unlock_irqrestore(&HFClock, flags);
>>  	}
>>  	if (test_bit(HFC_CHIP_2MBITRAW, &hc->chip)) {
>> -		if (hc->created[hc->chan[0].port] && hc->chan[ch].bch &&
>> +		ch = 0;
>> +		if (hc->created[hc->chan[ch].port] && 
>> hc->chan[ch].bch &&
>>  		    test_bit(FLG_ACTIVE, &hc->chan[ch].bch->Flags)) {
>>  			ch_activ++;
>> -			hfcmulti_tx(hc, 0);
>> -			hfcmulti_rx(hc, 0);
>> -			ch = 1;
>> +			hfcmulti_tx(hc, ch);
>> +			hfcmulti_rx(hc, ch);
>>  			if (hc->chan[ch].dch &&
>>  			    hc->chan[ch].nt_timer > -1) {
>>  				dch = hc->chan[ch].dch;
> 
> That seems to change the fields checked in the final 'if'.
> Not sure it is the intended behaviour.
> 

Yes it is the correct behavior, it was wrong before. If the
HFC_CHIP_2MBITRAW flag is set, only hc->chan[0] should be used.
This did not make trouble, because you normally do not use any
D-channnel in 2 MBit mode, calling the D-Channel specific functions
still makes sense for the L1 state machine, when using this
mode to emulate a E1 Layer1 tester, which was the main reson to
implement this mode.

Karsten
