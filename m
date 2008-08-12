From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem
 with fpu state changes
Date: Mon, 11 Aug 2008 17:42:21 -0700
Message-ID: <48A0DC6D.8040409@zytor.com>
References: <20080809143727.GA30499@gondor.apana.org.au> <200808091757.32999.wolfgang.walter@stwm.de> <489DC15D.9070308@zytor.com> <20080809185224.GH13158@linux-os.sc.intel.com> <20080809193724.GJ13158@linux-os.sc.intel.com> <20080810030521.GA2332@gondor.apana.org.au> <20080811190131.GL13158@linux-os.sc.intel.com> <20080811192203.GC12788@elte.hu> <48A0920B.30306@zytor.com> <20080811201901.GN13158@linux-os.sc.intel.com> <20080812003938.GC18230@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Suresh Siddha <suresh.b.siddha@intel.com>,
	Ingo Molnar <mingo@elte.hu>,
	Wolfgang Walter <wolfgang.walter@stwm.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:50355 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000AbYHLArh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 20:47:37 -0400
In-Reply-To: <20080812003938.GC18230@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Aug 11, 2008 at 01:19:01PM -0700, Suresh Siddha wrote:
> .
>> we can't unconditionally do clts() in the process context. We have
>> to disable pre-emption to avoid interactions with context switch and
>> lazy restore. So there will be RT latency issues aswell.
> 
> Yes disabling preemption is the real killer.
> 
> This is just a quick band-aid.  Longer term we should add a task
> flag that indicates the task is currently doing kernel FPU which
> will tell the scheduler to clear TS the next time it's run.  That
> way we won't need to disable preemtion or pollute the user task's
> FPU used state.

That's not sufficient, though, because you have to track all the state 
and how it relates to everything.  You now have to track both the 
userspace FPU state and the potential kernel FPU state.  The VIA 
instructions are special (in the short bus to school sense) in that they 
use a mechanism intended to protect specific state to protect -- exactly 
nothing.

	-hpa
