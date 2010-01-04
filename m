From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Subject: [PATCH 1/2] x86: get back 15 vectors
Date: Mon, 04 Jan 2010 13:10:54 -0800
Message-ID: <4B42595E.9010404@zytor.com>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>	<4B398ECD.1080506@kernel.org>	<4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>	<4B415E73.1050801@kernel.org> <4B419113.1090204@kernel.org>	<m1aawtlu6y.fsf@fess.ebiederm.org> <4B423B08.3010005@zytor.com>	<m1my0thelq.fsf@fess.ebiederm.org> <4B424305.7050803@kernel.org>	<4B4245FC.7070902@zytor.com> <4B424A5C.7080309@kernel.org> <m1y6kdbpad.fsf@fess.ebiederm.org> <4B425085.5040103@kernel.org>
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
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:33212 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955Ab0ADVL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 16:11:56 -0500
In-Reply-To: <4B425085.5040103@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2010 12:33 PM, Yinghai Lu wrote:
> --- linux-2.6.orig/arch/x86/include/asm/irq_vectors.h
> +++ linux-2.6/arch/x86/include/asm/irq_vectors.h
> @@ -30,8 +30,12 @@
>  /*
>   * IDT vectors usable for external interrupt sources start
>   * at 0x20:
> + * hpa said we can start from 0x1f.
> + *   0x1f is documented as reserved. The ability for the APIC to
> + *   generate vectors starting at 0x10 is documented, as is the ability for
> + *   the CPU to receive any vector number as an interrupt
>   */
> -#define FIRST_EXTERNAL_VECTOR		0x20
> +#define FIRST_EXTERNAL_VECTOR		0x1f
>  

This really isn't a sufficient explanation either.  I know writing
English prose is very difficult for you, but I'm sorry, you really need
to start getting better about your comments and commit messages.

In this case, the text is missing one very important piece of the
justification: otherwise we have to waste a full 16 vectors in order for
the IRQ migration interrupt to get its own priority level.  Thus,
something like this:

*   0x1f is documented as reserved.  However, the ability for the APIC
*   to generate vectors starting at 0x10 is documented, as is the
*   ability for the CPU to receive any vector number as an interrupt.
*   0x1f is used for IRQ_MOVE_CLEANUP_VECTOR since that vector needs
*   an entire privilege level (16 vectors) all by itself at a higher
*   priority than any actual device vector.  Thus, by placing it in the
*   otherwise-unusable 0x10 privilege level, we avoid wasting a full
*   16-vector block.

	-hpa
