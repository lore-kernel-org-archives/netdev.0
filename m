From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Subject: [PATCH 1/2] x86: get back 15 vectors
Date: Mon, 04 Jan 2010 11:01:28 -0800
Message-ID: <4B423B08.3010005@zytor.com>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>	<4B398ECD.1080506@kernel.org>	<4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>	<4B415E73.1050801@kernel.org> <4B419113.1090204@kernel.org> <m1aawtlu6y.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yinghai@kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753729Ab0ADTDJ@vger.kernel.org>
In-Reply-To: <m1aawtlu6y.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/04/2010 08:18 AM, Eric W. Biederman wrote:
> Yinghai Lu <yinghai@kernel.org> writes:
> 
> This patch is wrong.
> 
>> between FIRST_EXTERNAL_VECTOR (0x20) and FIRST_DEVICE_VECTOR (0x41)
>>
>> for 0x20 and 0x2f, we are safe be used_vectors will prevent it to use used one.
> 
> We can not use any of 0x20 - 0x2f for ioapic irqs.  We need the entire
> priority level to ensure that the irq move cleanup ipi is of a lower
> priority.
> 

Almost makes one want to abuse 0x1f for that.  Although 0x00..0x1f are
reserved for exceptions, the APICs range down to 0x10, and well, when
0x1f ends up actually getting used as an exception vector that we
support, then we can trivially change that.  In the meantime it would
actually make use of an otherwise-unusable APIC priority level.

	-hpa
