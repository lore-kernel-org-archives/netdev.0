From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH linux-next v2 1/2] irq: Add CPU mask affinity hint
Date: Fri, 30 Apr 2010 12:13:01 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.1004301212060.6636@PPWASKIE-MOBL2.amr.corp.intel.com>
References: <20100430085150.4630.46790.stgit@ppwaskie-hc2.jf.intel.com>
 <alpine.LFD.2.00.1004301249540.2951@localhost.localdomain>
 <Pine.WNT.4.64.1004301059230.6264@PPWASKIE-MOBL2.amr.corp.intel.com>
 <alpine.LFD.2.00.1004302038140.2951@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54671 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759469Ab0D3TNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 15:13:05 -0400
In-Reply-To: <alpine.LFD.2.00.1004302038140.2951@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Apr 2010, Thomas Gleixner wrote:

> On Fri, 30 Apr 2010, Peter P Waskiewicz Jr wrote:
>> On Fri, 30 Apr 2010, Thomas Gleixner wrote:
>>>> +extern int irq_register_affinity_hint(unsigned int irq,
>>>> +                                      const struct cpumask *m);
>>>
>>> I think we can do with a single funtion irq_set_affinity_hint() and
>>> let the caller set the pointer to NULL.
>>
>> Ok, I've been running into some issues.  If CONFIG_CPUMASK_OFFSTACK is not
>> set, then cpumask_var_t structs are single-element arrays that cannot be
>> NULL'd out.  I'm pretty sure I need to keep the unregister part of the API.
>> Thoughts?
>
> extern int irq_set_affinity_hint(unsigned int irq, const struct cpumask *m);
>
> So why should calling irq_set_affinity_hint(irqnr, NULL) not work ?

What was that you said about coffee and brain cells?  :-)

>
>> I just looked at the original show_affinity function, and it does not grab
>> desc->lock before copying mask out of desc.  Should I follow that model, or
>> should I fix that function to honor desc->lock?
>
> desc->affinity can only race against something changing the affinity
> bits, so that just might return some random data.
>
> In the hint case the irq could be shut down and the affinity hint
> could be freed while you are accessing it. Not a good idea :)

Good point.

Latest spin coming shortly.  Thanks for the quick feedback!

-PJ
