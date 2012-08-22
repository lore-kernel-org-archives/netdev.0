From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Tue, 21 Aug 2012 18:37:24 -0700
Message-ID: <503437D4.8090706@zytor.com>
References: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com> <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:36986 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754847Ab2HVBho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 21:37:44 -0400
In-Reply-To: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2012 06:23 PM, Ben Hutchings wrote:
> Define reado(), writeo() and their raw counterparts using SSE.
> 
> Based on work by Stuart Hodgson <smhodgson@solarflare.com>.

It would be vastly better if we explicitly controlled this with
kernel_fpu_begin()/kernel_fpu_end() rather than hiding it in primitives
than might tempt the user to do very much the wrong thing.

Also, it needs to be extremely clear to the user that these operations
use the FPU, and all the requirements there need to be met, including
not using them at interrupt time.

	-hpa
