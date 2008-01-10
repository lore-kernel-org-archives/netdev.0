From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Thu, 10 Jan 2008 11:01:30 -0800
Message-ID: <47866B8A.3040607@intel.com>
References: <478654C3.60806@nortel.com> <478666F4.50405@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <cfriesen@nortel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7760 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754671AbYAJTCR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 14:02:17 -0500
In-Reply-To: <478666F4.50405@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
>> 1) Interrupts are being processed on both cpus:
>>
>> root@base0-0-0-13-0-11-1:/root> cat /proc/interrupts
>>            CPU0       CPU1
>>  30:    1703756    4530785  U3-MPIC Level     eth0
> 
> IIRC none of the e1000 driven cards are multi-queue

the pci-express variants are, but the functionality is almost always disabled (and
relatively new anyway).

even with multiqueue, you can still have only a single irq line (which defeats the
purpose of course mostly).

>, so while the above 
> shows that interrupts from eth0 have been processed on both CPUs at
> various points in the past, it doesn't necessarily mean that they are
> being processed on both CPUs at the same time right?

never will, an irq can only be processed on one cpu at a time anyway, obviously
the irq here has been migrated ONCE from one of the cpu's to the other.
unfortunately you can't see from /proc/interrupts whether this happens frequently
or not, or how many times it happened before.

Auke
