From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem
 with fpu state changes
Date: Sat, 09 Aug 2008 09:10:05 -0700
Message-ID: <489DC15D.9070308@zytor.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080808231121.GA13158@linux-os.sc.intel.com> <20080809143727.GA30499@gondor.apana.org.au> <200808091757.32999.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Suresh Siddha <suresh.b.siddha@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:37712 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbYHIQQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 12:16:43 -0400
In-Reply-To: <200808091757.32999.wolfgang.walter@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Walter wrote:
> How could any kernel code use MMX/SSE/FPU when the interrupt case isn't 
> handled?

I don't think we have ever allowed MMX/SSE/FPU code in interrupt 
handlers.  kernel_fpu_begin()..end() lock out preemption, and so could 
only be interrupted, not preempted.

> Or is your argument that its lazy allocation itself is the problem: this 
> nesting could always happen and was a bug but only with lazy allocation it is 
> dangerous (as it may cause a spurious math fault in the race window).
> 
> If this were right than any kernel code executing SSE may trigger now a oops 
> in __switch_to() under some special circumstances.

If lazy allocation can cause the RAID code, for example (which executes 
SSE instructions in the kernel, but not at interrupt time) to start 
randomly oopsing, then lazy allocations have to be pulled.

	-hpa

