From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH linux-next v3 1/2] irq: Add CPU mask affinity hint
Date: Fri, 30 Apr 2010 14:18:29 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.1004301418130.6424@PPWASKIE-MOBL2.amr.corp.intel.com>
References: <20100430202343.4591.66240.stgit@ppwaskie-hc2.jf.intel.com>
 <1272661345.2110.28.camel@achroite.uk.solarflarecom.com>
 <alpine.LFD.2.00.1004302311550.2951@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:60552 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754191Ab0D3VSa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 17:18:30 -0400
In-Reply-To: <alpine.LFD.2.00.1004302311550.2951@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Apr 2010, Thomas Gleixner wrote:

> On Fri, 30 Apr 2010, Ben Hutchings wrote:
>> On Fri, 2010-04-30 at 13:23 -0700, Peter P Waskiewicz Jr wrote:
>>> +int irq_register_affinity_hint(unsigned int irq, const struct cpumask *m)
>>> +{
>>> +	struct irq_desc *desc = irq_to_desc(irq);
>>> +	unsigned long flags;
>>> +
>>> +	if (!desc)
>>> +		return -EINVAL;
>>
>> Is it possible for irq_to_desc(irq) to be NULL?  This function already
>> assumes that the caller 'owns' the IRQ.
>
> Oh come on. Driver writers get everything wrong and not checking on an
> invalid irq number is better than crashing :)
>
>>> +static int irq_affinity_hint_proc_show(struct seq_file *m, void *v)
>>> +{
>>> +	struct irq_desc *desc = irq_to_desc((long)m->private);
>>> +	unsigned long flags;
>>> +	cpumask_var_t mask;
>>> +	int ret = -EINVAL;
>>
>> I don't think this should be returning -EINVAL if the affinity hint is
>> missing.  That means 'invalid argument', but there is nothing invalid
>> about trying to read() the corresponding file.  The file should simply
>> be empty if there is no hint.  (Actually it might be better if it didn't
>> appear at all, but that would be a pain to implement.)
>
> I agree that -EINVAL is not really a good match.
>
> How about just returning CPU_MASK_ALL if desc->affinity_hint is not
> set ?

That seems reasonable to me.

cheers,
-PJ
