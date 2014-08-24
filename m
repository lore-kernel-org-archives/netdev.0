From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Sun, 24 Aug 2014 14:58:29 +0200
Message-ID: <20140824145829.1db31791@redhat.com>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
	<53F922D1.70409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752499AbaHXM6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Aug 2014 08:58:45 -0400
In-Reply-To: <53F922D1.70409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 23 Aug 2014 16:25:05 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On 08/23/2014 01:28 PM, David Miller wrote:
> > 
[...]
> > Typically a device queues up a packet in the TX queue and then has to
> > do something to have the device start processing that new entry.
> > Sometimes this is composed of doing an MMIO write to a "tail"
> > register, and in other cases it can involve something as expensive as
> > a hypervisor call.
> 
> The MMIO call isn't an issue until you encounter a locked operation, at
> least on x86 architecture.  So this often shows up in perf traces as a
> hit on the qdisc lock right after completing a transmit.  I've seen it
> at around 20% of CPU utilization when I was doing routing work with ixgbe.

My experience is that perf cannot measure these MMIO writes correctly.
Perf will often blame the lock operations in the qdisc system, but
playing with removing these qdisc and TXQ locks, I found that perf
would start blaming some asm inst that did not make sense (adjusting
the code, would make perf blame another asm inst that didn't make sense).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
