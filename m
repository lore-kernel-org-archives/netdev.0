From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem
	with fpu state changes
Date: Mon, 11 Aug 2008 21:22:03 +0200
Message-ID: <20080811192203.GC12788@elte.hu>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080808231121.GA13158@linux-os.sc.intel.com> <20080809143727.GA30499@gondor.apana.org.au> <200808091757.32999.wolfgang.walter@stwm.de> <489DC15D.9070308@zytor.com> <20080809185224.GH13158@linux-os.sc.intel.com> <20080809193724.GJ13158@linux-os.sc.intel.com> <20080810030521.GA2332@gondor.apana.org.au> <20080811190131.GL13158@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Wolfgang Walter <wolfgang.walter@stwm.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:34371 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751760AbYHKTW0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 15:22:26 -0400
Content-Disposition: inline
In-Reply-To: <20080811190131.GL13158@linux-os.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Suresh Siddha <suresh.b.siddha@intel.com> wrote:

> Reported-and-bisected-by: Wolfgang Walter <wolfgang.walter@stwm.de>
> Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>

no fundamental objection to the x86 bits.

shouldnt this:

+       if (!in_interrupt())
+               return 0;

just be eliminated and the cr0/TS save/restore be made unconditional?  
irq-assymetric APIs are not nice in general.

Reading/setting cr0 isnt _that_ slow. (or if it is, by how much does it 
slow things down, exactly?)

	Ingo
