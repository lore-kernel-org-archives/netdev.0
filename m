From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] net: myri10ge: convert to hw_features
Date: Fri, 15 Apr 2011 14:36:41 -0400
Message-ID: <4DA89039.2070507@myri.com>
References: <20110415145050.0D65C13A66@rere.qmqm.pl> <20110415182922.GA2458@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Brice Goglin <brice@myri.com>
To: Jon Mason <jon.mason@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:62691 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489Ab1DOSgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 14:36:49 -0400
Received: by gwaa18 with SMTP id a18so1199382gwa.19
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 11:36:48 -0700 (PDT)
In-Reply-To: <20110415182922.GA2458@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/11 14:29, Jon Mason wrote:
> On Fri, Apr 15, 2011 at 04:50:50PM +0200, Micha=C5=82 Miros=C5=82aw w=
rote:
>> Signed-off-by: Micha=C5=82 Miros=C5=82aw<mirq-linux@rere.qmqm.pl>
>> ---
>>   drivers/net/myri10ge/myri10ge.c |   66 +++++++--------------------=
-----------
>>   1 files changed, 12 insertions(+), 54 deletions(-)
>>
>> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/=
myri10ge.c
>> index 1446de5..a48eb92 100644
>> --- a/drivers/net/myri10ge/myri10ge.c
>> +++ b/drivers/net/myri10ge/myri10ge.c
>> @@ -205,7 +205,6 @@ struct myri10ge_priv {
>>   	int tx_boundary;	/* boundary transmits cannot cross */
>>   	int num_slices;
>>   	int running;		/* running?             */
>> -	int csum_flag;		/* rx_csums?            */
>
> Get rid of MXGEFW_FLAGS_CKSUM in drivers/net/myri10ge/myri10ge_mcp.h,
> as this was the only thing using it.
>

No, please don't.  MXGEFW_FLAGS_CKSUM is a TX descriptor flag that was=20
(ab)used as a device state flag as well. See flags in myri10ge_xmit().=20
I think early in the development process, the value of  mgp->csum_flag=20
was directly assigned into the descriptor, which is why they shared the=
=20
value.

Drew
