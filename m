From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Subject: [PATCH 1/2] x86: get back 15 vectors
Date: Mon, 04 Jan 2010 11:04:46 -0800
Message-ID: <m1vdfhhesx.fsf@fess.ebiederm.org>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>
	<4B398ECD.1080506@kernel.org>
	<4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>
	<4B415E73.1050801@kernel.org> <4B419113.1090204@kernel.org>
	<m1aawtlu6y.fsf@fess.ebiederm.org> <4B42362F.7040302@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57051 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643Ab0ADTE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 14:04:56 -0500
In-Reply-To: <4B42362F.7040302@kernel.org> (Yinghai Lu's message of "Mon\, 04 Jan 2010 10\:40\:47 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yinghai Lu <yinghai@kernel.org> writes:

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
>>> also try to reuse 0x30 to 0x3f after smp_affinity for irq[0,15] is changed to other cpu.
>> 
>> There may be a point with 0x30 to 0x3f as I recall when those irqs come through a legacy
>> pic we need to reserve those vectors on all cpus.
>
> ok, I see.
>
> any reason that we can not use 0x40?

Not that I now of.  Reading the comment it looks like it was only
skipped so that the initial assignment of vectors would be.

0x31, 0x41, 0x51, 0x61, 0x71, 0x81, 0x91, 0xa1, 0xb1, 0xc1, 0xd1, 0xe1
Instead of.
0x30, 0x40, 0x50, 0x60, 0x70, 0x90, 0xa0, 0xb0, 0xc0, 0xc0, 0xe0

Which doesn't seem to be the worst notion, but at the point we are looking
for every vector we can get it does seem to be problematic.

Eric
