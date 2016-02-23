From: "Christopher Hall" <christopher.s.hall@intel.com>
Subject: Re: [PATCH v7 6/8] x86: tsc: Always Running Timer (ART) correlated
 clocksource
Date: Mon, 22 Feb 2016 18:38:11 -0800
Message-ID: <op.yc9llxxf1774gr@chall-mobl2.amr.corp.intel.com>
References: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
 <1455308729-6280-7-git-send-email-christopher.s.hall@intel.com>
 <56C63385.9050703@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: x86@kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	kevin.b.stanton@intel.com, kevin.j.clarke@intel.com
To: tglx@linutronix.de, richardcochran@gmail.com, mingo@redhat.com,
	john.stultz@linaro.org, hpa@zytor.com, jeffrey.t.kirsher@intel.com,
	"Andy Lutomirski" <luto@kernel.org>,
	"Peter Zijlstra" <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:47286 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756769AbcBWCiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2016 21:38:14 -0500
In-Reply-To: <56C63385.9050703@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Feb 2016 13:11:33 -0800, Andy Lutomirski <luto@kernel.org>  
wrote:
>> +#define X86_FEATURE_INVARIANT_TSC (7*32+4) /* Intel Invariant TSC */

This is removed. It was basically an alias for NONSTOP_TSC and not needed.

>
>> +/*
>> + * Convert ART to TSC given numerator/denominator found in detect_art()
>> + */
>> +struct system_counterval_t convert_art_to_tsc(cycle_t art)
>> +{
>> +	u64 tmp, res, rem;
>> +
>> +	rem = do_div(art, art_to_tsc_denominator);
>> +
>> +	res = art * art_to_tsc_numerator;
>> +	tmp = rem * art_to_tsc_numerator;
>> +
>> +	do_div(tmp, art_to_tsc_denominator);
>> +	res += tmp;
>> +
>> +	return (struct system_counterval_t) {.cs = art_related_clocksource,
>> +			.cycles = res};
>
> The SDM and the patch description both mention an offset "k".  Shouldn't  
> this code at least have a comment about how it deals with the k != 0  
> case?

I don't deal with the k != 0 case. I assume that IA32 TSC adjust MSR is 0  
because it's almost always a *bad idea* to change it. I've discussed this  
with a few other developers and there is some consensus agreeing. From an  
earlier related thread Peter Zijlstra asserts that TSC adjust "had
better" be 0.(http://lkml.iu.edu/hypermail/linux/kernel/1507.3/03734.html).

Do we really need to accommodate BIOS's that do this?

Chris
