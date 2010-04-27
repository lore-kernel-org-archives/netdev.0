From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH RFC: linux-next 1/2] irq: Add CPU mask affinity hint
 callback framework
Date: Tue, 27 Apr 2010 09:04:25 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.1004270856560.320@PPWASKIE-MOBL2.amr.corp.intel.com>
References: <20100419045741.30276.23233.stgit@ppwaskie-hc2.jf.intel.com>
 <alpine.LFD.2.00.1004271425140.2951@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7401 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755433Ab0D0QE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 12:04:27 -0400
In-Reply-To: <alpine.LFD.2.00.1004271425140.2951@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Apr 2010, Thomas Gleixner wrote:

> On Sun, 18 Apr 2010, Peter P Waskiewicz Jr wrote:
>> +/**
>> + * struct irqaffinityhint - per interrupt affinity helper
>> + * @callback:	device driver callback function
>> + * @dev:	reference for the affected device
>> + * @irq:	interrupt number
>> + */
>> +struct irqaffinityhint {
>> +	irq_affinity_hint_t callback;
>> +	void *dev;
>> +	int irq;
>> +};
>
> Why do you need that extra data structure ? The device and the irq
> number are known, so all you need is the callback itself. So no need
> for allocating memory ....

When I register the function callback with the interrupt layer, I need to 
know what device structures to reference back in the driver.  In other 
words, if I call into an underlying driver with just an interrupt number, 
then I have no way at getting at the dev structures (netdevice for me, 
plus my private adapter structures), unless I declare them globally 
(yuck).

I had a different approach before this one where I assumed the device from 
the irq handler callback was safe to use for the device in this new 
callback.  I didn't feel really great about that, since it's an implicit 
assumption that could cause things to go sideways really quickly.

Let me know what you think either way.  I'm certainly willing to make a 
change, I just don't know at this point what's the safest approach from 
what I currently have.

>
>> +static ssize_t irq_affinity_hint_proc_write(struct file *file,
>> +		const char __user *buffer, size_t count, loff_t *pos)
>> +{
>> +	/* affinity_hint is read-only from proc */
>> +	return -EOPNOTSUPP;
>> +}
>> +
>
> Why do you want a write function when the file is read only ?

It's leftover paranoia.  I put it in early on, then changed the mode 
later.  I can remove this function.  I'll re-send something once we agree 
on how the code in your first comment should look.

Thanks Thomas!

-PJ
