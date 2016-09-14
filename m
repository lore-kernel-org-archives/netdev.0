From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 8/9] net: ethernet: ti: cpts: fix overflow check period
Date: Wed, 14 Sep 2016 23:03:18 +0300
Message-ID: <d4cde14a-8147-6097-f034-c9cde6cdb718@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-9-grygorii.strashko@ti.com>
 <20160914142503.GF28592@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:44729 "EHLO bear.ext.ti.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755879AbcINUDY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 16:03:24 -0400
In-Reply-To: <20160914142503.GF28592@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2016 05:25 PM, Richard Cochran wrote:
> On Wed, Sep 14, 2016 at 04:02:30PM +0300, Grygorii Strashko wrote:
>> @@ -427,9 +427,6 @@ static void cpts_calc_mult_shift(struct cpts *cpts)
>>  	u64 ns;
>>  	u64 frac;
>>  
>> -	if (cpts->cc_mult || cpts->cc.shift)
>> -		return;
>> -
>>  	freq = clk_get_rate(cpts->refclk);
>>  
>>  	/* Calc the maximum number of seconds which we can run before
> 
> This hunk has nothing to do with $subject.

Sry, but I did not get your comment here :(
I'd happy to update patch according to your request, but could you provide more info here, pls?



> 
>> @@ -442,11 +439,20 @@ static void cpts_calc_mult_shift(struct cpts *cpts)
>>  	else if (maxsec > 600 && cpts->cc.mask > UINT_MAX)
>>  		maxsec = 600;
>>  
>> +	/* Calc overflow check period (maxsec / 2) */
>> +	cpts->ov_check_period = (HZ * maxsec) / 2;
>> +	dev_info(cpts->dev, "cpts: overflow check period %lu\n",
>> +		 cpts->ov_check_period);
>> +
>> +	if (cpts->cc_mult || cpts->cc.shift)
>> +		return;
>> +
>>  	clocks_calc_mult_shift(&mult, &shift, freq, NSEC_PER_SEC, maxsec);
>>  
>>  	cpts->cc_mult = mult;
>>  	cpts->cc.mult = mult;
>>  	cpts->cc.shift = shift;
>> +
> 
> Nor does this.



-- 
regards,
-grygorii
