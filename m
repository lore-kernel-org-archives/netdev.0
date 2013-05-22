From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v3 net-next 0/4] net: low latency Ethernet device polling
Date: Wed, 22 May 2013 12:35:21 +0300
Message-ID: <519C9159.7050807@linux.intel.com>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>  <519B632F.7040202@mellanox.com> <519B68A4.3010406@linux.intel.com> <1369160115.2615.51.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Rosenbaum <alexr@mellanox.com>,
	Dave Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53915 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752610Ab3EVJf0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 05:35:26 -0400
In-Reply-To: <1369160115.2615.51.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 21/05/2013 21:15, Ben Hutchings wrote:
> On Tue, 2013-05-21 at 15:29 +0300, Eliezer Tamir wrote:
>> Many of the questions you asked are covered in our RFC cover letter, but
>> I will touch them briefly
>>
>> On 21/05/2013 15:06, Alex Rosenbaum wrote:
>>> 1. It seem this patch does not cover epoll/select and such IO muxing APIs?
>>
>> We are thinking about how to implement epoll support as one of the next
>> steps.
>>
>> What benchmarks are you using to test poll/select/epoll?
> [...]
>
> I raised this issue back at Plumbers and I thought Jesse said poll() was
> covered.  It's likely to be a bit of a toy without that.  Also, UDP?

The current patchset covers poll/select for UDP.
Adding poll/select for TCP should be simple, I will try to include it in 
the next version.

Epoll should see a gain from the above in the case where all the polled 
file descriptors are associated to the same device queue.
A fuller implementation, in the epoll itself would be needed to cover 
multiple queues/devices.
