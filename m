From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v2 12/13] net: ethernet: ti: cpts: calc mult and shift
 from refclk freq
Date: Tue, 29 Nov 2016 10:22:21 -0600
Message-ID: <cfa767c3-9ff4-d1b3-14a2-2f2118356bf1@ti.com>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
 <20161128230337.6731-13-grygorii.strashko@ti.com>
 <20161129103453.GJ3110@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161129103453.GJ3110@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/29/2016 04:34 AM, Richard Cochran wrote:
> On Mon, Nov 28, 2016 at 05:03:36PM -0600, Grygorii Strashko wrote:
>> +static void cpts_calc_mult_shift(struct cpts *cpts)
>> +{
>> +	u64 frac, maxsec, ns;
>> +	u32 freq, mult, shift;
>> +
>> +	freq = clk_get_rate(cpts->refclk);
>> +
>> +	/* Calc the maximum number of seconds which we can run before
>> +	 * wrapping around.
>> +	 */
>> +	maxsec = cpts->cc.mask;
>> +	do_div(maxsec, freq);
>> +	if (maxsec > 600 && cpts->cc.mask > UINT_MAX)
>> +		maxsec = 600;
> 
> The reason for this test is not obvious.  Why check cc.mask against
> UINT_MAX?  Please use the comment to explain it.
> 

Yeah. This is copy paste from __clocksource_update_freq_scale(), but
I'm going to limit it to 10 sec for now, because otherwise it will result in too small
mult in case of 64bit counter.

if (maxsec > 10)
	maxsec = 10;

-- 
regards,
-grygorii
