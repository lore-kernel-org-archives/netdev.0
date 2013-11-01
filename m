From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Fri, 1 Nov 2013 13:37:01 -0400
Message-ID: <20131101173701.GC8467@hmsreliant.think-freely.org>
References: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com>
 <20131030110214.GA10220@localhost.localdomain>
 <52710B09.6090302@redhat.com>
 <20131031183003.GC25894@hmsreliant.think-freely.org>
 <1383320566.1737.0.camel@bwh-desktop.uk.level5networks.com>
 <20131101160802.GB8467@hmsreliant.think-freely.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B73D3@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Doug Ledford <dledford@redhat.com>,
	Ingo Molnar <mingo@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54515 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab3KARhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 13:37:22 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73D3@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 01, 2013 at 04:18:50PM -0000, David Laight wrote:
> > How would you suggest replacing the jumps in this case?  I agree it would be
> > faster here, but I'm not sure how I would implement an increment using a single
> > conditional move.
> 
> I think you need 3 instructions, move a 0, conditionally move a 1
> then add. I suspect it won't be a win!
> 
> If you do 'win' it is probably very dependent on how the instructions
> get scheduled onto the execution units - which will probably make
> it very cpu type dependant.
> 
> 	David
> 
I agree, that sounds interesting, but very cpu dependent.  Thanks for the
suggestion, Ben, but I think it would be better if we just did the prefetch here
and re-addressed this area when AVX (or addcx/addox) instructions were available
for testing on hardware.

Neil
