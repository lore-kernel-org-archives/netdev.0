From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 4/6] net: ethernet: ti: cpts: add ptp pps support
Date: Wed, 30 Nov 2016 14:43:57 -0600
Message-ID: <875d4cc2-8a47-b06d-fb46-0cacc28dbaee@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-5-grygorii.strashko@ti.com>
 <20161130184511.GB8209@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:50295 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756680AbcK3UoC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 15:44:02 -0500
In-Reply-To: <20161130184511.GB8209@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/30/2016 12:45 PM, Richard Cochran wrote:
> On Mon, Nov 28, 2016 at 05:04:26PM -0600, Grygorii Strashko wrote:
>> +static cycle_t cpts_cc_ns2cyc(struct cpts *cpts, u64 nsecs)
>> +{
>> +	cycle_t cyc = (nsecs << cpts->cc.shift) + nsecs;
>> +
>> +	do_div(cyc, cpts->cc.mult);
>> +
>> +	return cyc;
>> +}
> 
> So you set the comparison value once per second, based on cc.mult.
> But when the clock is being actively synchronized, user space calls to
> clock_adjtimex() will change cc.mult.  This can happen several times
> per second, depending on the PTP Sync rate.
> 

Right.

> In order to produce the PPS edge correctly, you would have to adjust
> the comparison value whenever cc.mult changes, 

yes. And that is done in cpts_ptp_adjfreq()
	if (cpts->ts_comp_enabled)
		cpts->ts_comp_one_sec_cycs = cpts_cc_ns2cyc(cpts, NSEC_PER_SEC);
	^^^ re-calculate reload value for 
 
	cpts_ts_comp_settime(cpts, ns);
	^^^ adjust the ts_comp

> but of course this is unworkable.
> 

Sry, but this is questionable - code for pps comes from TI internal
branches (SDK releases) where it survived for a pretty long time.
I'm, of course, agree that without HW support for freq adjustment
this PPS feature is not super precise and has some limitation,
but that is what we agree to live with. 

Murali, do you have any comments regarding usability of SW
freq freq adjustment approach? 

> So I'll have to say NAK for this patch.
> 

:) 


-- 
regards,
-grygorii
