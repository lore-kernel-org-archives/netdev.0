From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v2 1/3] can: c_can_platform: Fix c_can_hw_raminit_ti()
 and add timeout
Date: Tue, 9 Sep 2014 17:54:26 +0300
Message-ID: <540F14A2.6000904@ti.com>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com> <1410273070-22485-2-git-send-email-rogerq@ti.com> <540F0FEE.2040202@ti.com> <540F1294.9080107@ti.com> <540F13E4.7020907@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <tony@atomide.com>, <tglx@linutronix.de>, <mugunthanvnm@ti.com>,
	<george.cherian@ti.com>, <balbi@ti.com>, <nsekhar@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>
To: Nishanth Menon <nm@ti.com>, <wg@grandegger.com>,
	<mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:60773 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbaIIOyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 10:54:55 -0400
In-Reply-To: <540F13E4.7020907@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2014 05:51 PM, Nishanth Menon wrote:
> On 09/09/2014 09:45 AM, Roger Quadros wrote:
> [...]
>>>>  	/* We look only at the bits of our instance. */
>>>>  	val &= mask;
>>>> -	while ((readl(priv->raminit_ctrlreg) & mask) != val)
>>>> +	while ((readl(priv->raminit_ctrlreg) & mask) != val) {
>>>>  		udelay(1);
>>>> +		timeout++;
>>>> +
>>>> +		if (timeout == 1000) {
>>>
>>> How did we come up with this number?
>>
>> wild guess ;), that it should be set in a few microseconds and the delay is not too
>> large.
>>
>> Till I don't hear from hardware guys, it will remain a guess.
>>
> 
> in cases like these, I suggest using emperical data as point ->
> example doing some 10,000 iterations of the operation and picking up
> the worse case number and double it.

In my tests the bit was either set immediately or never at all.
Not sure if we should increase it further.

> 
> Either way, you need to document the same, else a few years down the
> line, when that number is in question, no one will know what it's
> basis was..
> 

OK. I'll add a comment there.

cheers,
-roger
