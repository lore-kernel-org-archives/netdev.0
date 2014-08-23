From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Sat, 23 Aug 2014 16:25:05 -0700
Message-ID: <53F922D1.70409@gmail.com>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:54525 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbaHWXZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 19:25:12 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so18287960pad.36
        for <netdev@vger.kernel.org>; Sat, 23 Aug 2014 16:25:07 -0700 (PDT)
In-Reply-To: <20140823.132811.751469424156827125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2014 01:28 PM, David Miller wrote:
> 
> Over time, and specifically and more recently at the Networking
> Workshop during Kernel SUmmit in Chicago, we have discussed the idea
> of having some way to optimize transmits of multiple TX packets at
> a time.
> 
> There are several areas of overhead that could be amortized with such
> schemes.  One has to do with locking and transactional overhead, the
> other has to do with device specific costs.
> 
> This patch set here is more aimed at device specific costs.
> 
> Typically a device queues up a packet in the TX queue and then has to
> do something to have the device start processing that new entry.
> Sometimes this is composed of doing an MMIO write to a "tail"
> register, and in other cases it can involve something as expensive as
> a hypervisor call.

The MMIO call isn't an issue until you encounter a locked operation, at
least on x86 architecture.  So this often shows up in perf traces as a
hit on the qdisc lock right after completing a transmit.  I've seen it
at around 20% of CPU utilization when I was doing routing work with ixgbe.

Thanks,

Alex
