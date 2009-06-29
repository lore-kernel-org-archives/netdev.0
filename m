From: Andi Kleen <andi@firstfloor.org>
Subject: Re: kerneloops.org report for the week
Date: Mon, 29 Jun 2009 11:05:03 +0200
Message-ID: <87iqifl8ao.fsf@basil.nowhere.org>
References: <20090628091055.12a4fb9e@infradead.org>
	<20090629031804.GA6764@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, x86@kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:36139 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbZF2JFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 05:05:04 -0400
In-Reply-To: <20090629031804.GA6764@elte.hu> (Ingo Molnar's message of "Mon, 29 Jun 2009 05:18:04 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar <mingo@elte.hu> writes:
>
>> Rank 8: generic_get_mtrr (warning)
>> 	Reported 544 times (2061 total reports)
>> 	BIOS bug where the MTRRs are not set up correctly
>> 	This warning was last seen in version 2.6.30, and first seen in 2.6.25.3.
>> 	More info: http://www.kerneloops.org/searchweek.php?search=generic_get_mtrr
>
> I think this calls for enabling the x86 MTRR sanitizer by default - 
> 500 out of 15000 reports suggests a significant proportion of Linux 
> systems is affected by MTRR setup problems.

The question is if the MTRRs are really wrong. The generic.c code checks
against the maximum address space reported by the CPU, but the BIOS might
only sets up the address space that is actually used. The later
is not really wrong; it's not needed to set MTRRs for non existing
mappings.

It might be better to double check against the max e820 mapping too
or drop that check.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
