From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [RFC/PATCH 2/3] UDP memory usage accounting: accounting unit
 and variable
Date: Thu, 27 Sep 2007 14:54:30 -0400
Message-ID: <46FBFC66.7060907@redhat.com>
References: <46F3B88D.1030601@hitachi.com> <p734pho9nb9.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47261 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757326AbXI0Syk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 14:54:40 -0400
In-Reply-To: <p734pho9nb9.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I apologize for not replying sooner.

Andi Kleen wrote:
> Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com> writes:
> 
>> This patch introduces global variable for UDP memory accounting.
>> The unit is page.
> 
> The global variable doesn't seem to be very MP scalable, especially
> if you change it for each packet. This will be a very hot cache line,
> in the worst case bouncing around a large machine.
> 
> Possible alternatives:
> - Per CPU variables
> - You only change the global on socket creation time (by pre allocating a large
> amount) or when the system comes under memory pressure.
> - Batching of the global updates for multiple packets [that's a variant
> of the previous one, might be still too costly though]
> 
> Also for such variables it's usually good to cache line pad them on SMP
> to avoid false sharing with something else.
> 
> -Andi

Thank you so much for your suggestions.

The implementation of the patch basically followed implementation of
tcp_memory_allocated. However, I should agree that the patch introduces
atomic operations too much. Then, I'll try to use the batching to reduce
the number of atomic operations.

Best regards,
Hideo Aoki

--
Hitachi Computer Products (America) Inc.
