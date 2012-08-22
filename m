From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 03:04:11 +0100
Message-ID: <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com>
	 <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
	 <503437D4.8090706@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <x86@kernel.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55617 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754863Ab2HVCEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 22:04:15 -0400
In-Reply-To: <503437D4.8090706@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-21 at 18:37 -0700, H. Peter Anvin wrote:
> On 08/21/2012 06:23 PM, Ben Hutchings wrote:
> > Define reado(), writeo() and their raw counterparts using SSE.
> > 
> > Based on work by Stuart Hodgson <smhodgson@solarflare.com>.
> 
> It would be vastly better if we explicitly controlled this with
> kernel_fpu_begin()/kernel_fpu_end() rather than hiding it in primitives
> than might tempt the user to do very much the wrong thing.
> 
> Also, it needs to be extremely clear to the user that these operations
> use the FPU, and all the requirements there need to be met, including
> not using them at interrupt time.

Well we can sometimes use the FPU state at IRQ time, can't we
(irq_fpu_usable())?   So we might need, say, try_reado() and
try_writeo() with callers expected to fall back to alternatives.  (Which
they must have anyway for any architecture that doesn't support this.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
