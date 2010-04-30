From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH linux-next v4 2/2] ixgbe: Example usage of the new IRQ
 affinity_hint callback
Date: Fri, 30 Apr 2010 14:51:34 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.1004301449440.6512@PPWASKIE-MOBL2.amr.corp.intel.com>
References: <20100430214445.3992.41647.stgit@ppwaskie-hc2.jf.intel.com>
 <20100430214517.3992.92545.stgit@ppwaskie-hc2.jf.intel.com>
 <alpine.LFD.2.00.1004302346030.2951@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36706 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293Ab0D3Vvg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 17:51:36 -0400
In-Reply-To: <alpine.LFD.2.00.1004302346030.2951@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Apr 2010, Thomas Gleixner wrote:

> On Fri, 30 Apr 2010, Peter P Waskiewicz Jr wrote:
>> +	for (i = 0; i < num_q_vectors; i++) {
>> +		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
>> +		/* release the CPU mask memory */
>> +		free_cpumask_var(q_vector->affinity_mask);
>> +		/* clear the affinity_mask in the IRQ descriptor */
>> +		irq_set_affinity_hint(adapter->msix_entries[i].vector, NULL);
>
> Freeing the mask _AFTER_ clearing the hint might be a worthwhile
> exercise :)

Crap.  I had it reversed before, then when I dropped the unregister call 
it got swapped.  I'll fix it on the official submission for this one.

This patch is just an example patch, not to be merged just now.  Once the 
IRQ side is merged, and DaveM has that pulled into a tree, I'll send an 
official ixgbe patch using the API.  But I'll be sure to have this fixed 
before sending. :-)

-PJ
