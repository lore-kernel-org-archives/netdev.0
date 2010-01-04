From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Subject: [PATCH 1/2] x86: get back 15 vectors
Date: Mon, 04 Jan 2010 11:09:05 -0800
Message-ID: <m1my0thelq.fsf@fess.ebiederm.org>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>
	<4B398ECD.1080506@kernel.org>
	<4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>
	<4B415E73.1050801@kernel.org> <4B419113.1090204@kernel.org>
	<m1aawtlu6y.fsf@fess.ebiederm.org> <4B423B08.3010005@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yinghai@kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56281 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753814Ab0ADTJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 14:09:10 -0500
In-Reply-To: <4B423B08.3010005@zytor.com> (H. Peter Anvin's message of "Mon\, 04 Jan 2010 11\:01\:28 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"H. Peter Anvin" <hpa@zytor.com> writes:

> On 01/04/2010 08:18 AM, Eric W. Biederman wrote:
>> Yinghai Lu <yinghai@kernel.org> writes:
>> 
>> This patch is wrong.
>> 
>>> between FIRST_EXTERNAL_VECTOR (0x20) and FIRST_DEVICE_VECTOR (0x41)
>>>
>>> for 0x20 and 0x2f, we are safe be used_vectors will prevent it to use used one.
>> 
>> We can not use any of 0x20 - 0x2f for ioapic irqs.  We need the entire
>> priority level to ensure that the irq move cleanup ipi is of a lower
>> priority.
>> 
>
> Almost makes one want to abuse 0x1f for that.  Although 0x00..0x1f are
> reserved for exceptions, the APICs range down to 0x10, and well, when
> 0x1f ends up actually getting used as an exception vector that we
> support, then we can trivially change that.  In the meantime it would
> actually make use of an otherwise-unusable APIC priority level.

An optimization like that (with a big fat comment) seems reasonable
to me.

Eric
