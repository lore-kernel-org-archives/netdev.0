From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: Subject: [PATCH 1/2] x86: get back 15 vectors
Date: Mon, 04 Jan 2010 15:32:28 -0800
Message-ID: <4B427A8C.1040902@kernel.org>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>	<4B398ECD.1080506@kernel.org>	<4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>	<4B415E73.1050801@kernel.org> <4B419113.1090204@kernel.org>	<m1aawtlu6y.fsf@fess.ebiederm.org> <4B423B08.3010005@zytor.com>	<m1my0thelq.fsf@fess.ebiederm.org> <4B424305.7050803@kernel.org>	<4B4245FC.7070902@zytor.com> <4B424A5C.7080309@kernel.org> <m1y6kdbpad.fsf@fess.ebiederm.org> <4B425085.5040103@kernel.org> <4B42595E.9010404@zytor.com> <4B425BB7.90501@kernel.org> <4B425EB5.5080504@zytor.com> <4B426550.6000209@kernel.org> <4B4273D4.2080709@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Suresh Siddha <suresh.b.siddha@intel.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:58502 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753756Ab0ADXd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 18:33:58 -0500
In-Reply-To: <4B4273D4.2080709@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2010 03:03 PM, H. Peter Anvin wrote:
> On 01/04/2010 02:01 PM, Yinghai Lu wrote:
>>>
>>>>  /*
>>>> + * First APIC vector available to drivers: (vectors 0x30-0xee) we
>>>> + * start at 0x31 to spread out vectors evenly between priority
>>>> + * levels. (0x80 is the syscall vector)
>>>> + */
>>>> +#define FIRST_DEVICE_VECTOR		(IRQ15_VECTOR + 2)
>>>> +
>>>
>>> We really should fix that so we can do +1 here instead of +2; that
>>> presumably means fixing the logic so we do something smarter than just
>>> jump over 0x80.
>>
>> we already use used_vectors to skip 0x80. so we could change that to +1?
>>
> 
> Yes, but the problem is that we *skip* 0x80, which leads to suboptimal
> allocation on systems with only a handful of vectors.
> 
> The easy solution to accomplishing what we want without wasting vector
> 0x30 is obviously to start allocation at 0x31, but not by artificially
> limiting the vector space; see the attached patch.
> 
> For what it's worth, this code(__assign_irq_vector() in
> arch/x86/kernel/apic/io_apic.c) has me somewhat confused about the use
> of the constant 8:
> 
> 		vector += 8;
> 
> The only justification that I can immediately think of is to try to
> assign exactly two sources to each priority level (since early APICs
> started losing interrupts with more than two sources per priority level.)
> 
> This is ancient code -- predates not just the git but the bk history --
> and as such I would assume that that is the motivation.

yes the patch get back 0x30, 0x38, 0x40, 0x48 etc back.

YH
