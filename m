From: "Hong H. Pham" <hong.pham@windriver.com>
Subject: Re: [PATCH 0/1] NIU: fix spurious interrupts
Date: Tue, 19 May 2009 17:52:15 -0400
Message-ID: <4A132A0F.8070800@windriver.com>
References: <1242068453-5124-1-git-send-email-hong.pham@windriver.com> <20090518.220911.102225532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matheos.worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:59657 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860AbZESVwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 17:52:17 -0400
In-Reply-To: <20090518.220911.102225532.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Thanks for tracking down this problem, but I want to understand
> why this even happens.  As far as I can tell it shouldn't.
> 
> When we are done polling, the order of events is:
> 
> 1) unmask LDG interrupt(s)
> 2) napi_complete()
> 3) rearm LDG interrupt(s)
> 
> The interrupts should not be sent again until that rearm operation,
> which is after NAPI is completed.  So the condition you are hitting
> does not seem possible.

My thoughts exactly... this should not happen.

> Matheos, can the chip violate this?  If an RX event is reported
> in an LDG, it is masked, and then unmaked the interrupt should
> not appear until the LDG is also rearmed right?

Unfortunately I don't have a PCIe NIU card to test in an x86 box.  If
the hang does not happen on x86 (which is my suspicion), that would rule
out a problem with the NIU chip.  That would mean there's some
interaction between the NIU and sun4v hypervisor that's causing the
spurious interrupts.

Hong
