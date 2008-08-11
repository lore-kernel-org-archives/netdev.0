From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem
 with fpu state changes
Date: Mon, 11 Aug 2008 12:24:59 -0700
Message-ID: <48A0920B.30306@zytor.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080808231121.GA13158@linux-os.sc.intel.com> <20080809143727.GA30499@gondor.apana.org.au> <200808091757.32999.wolfgang.walter@stwm.de> <489DC15D.9070308@zytor.com> <20080809185224.GH13158@linux-os.sc.intel.com> <20080809193724.GJ13158@linux-os.sc.intel.com> <20080810030521.GA2332@gondor.apana.org.au> <20080811190131.GL13158@linux-os.sc.intel.com> <20080811192203.GC12788@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Suresh Siddha <suresh.b.siddha@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Wolfgang Walter <wolfgang.walter@stwm.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:54579 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755480AbYHKTbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 15:31:49 -0400
In-Reply-To: <20080811192203.GC12788@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * Suresh Siddha <suresh.b.siddha@intel.com> wrote:
> 
>> Reported-and-bisected-by: Wolfgang Walter <wolfgang.walter@stwm.de>
>> Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
> 
> no fundamental objection to the x86 bits.
> 
> shouldnt this:
> 
> +       if (!in_interrupt())
> +               return 0;
> 
> just be eliminated and the cr0/TS save/restore be made unconditional?  
> irq-assymetric APIs are not nice in general.
> 
> Reading/setting cr0 isnt _that_ slow. (or if it is, by how much does it 
> slow things down, exactly?)
> 

Setting it is relatively slow.  I think that's part of the reason for 
special instructions to muck with the TS flag.

Reading it might be slow on obsolete processors.

	-hpa
