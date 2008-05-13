From: Jeff Garzik <jeff@garzik.org>
Subject: Re: network devices: to IRQF_SAMPLE_RANDOM or not to IRQF_SAMPLE_RANDOM?
Date: Tue, 13 May 2008 13:33:33 -0400
Message-ID: <4829D0ED.5010701@garzik.org>
References: <a24804730805130949o32687f74id4fce833c3589641@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, NetDev <netdev@vger.kernel.org>
To: Chris Peterson <cpeterso@cpeterso.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49496 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226AbYEMRdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 13:33:35 -0400
In-Reply-To: <a24804730805130949o32687f74id4fce833c3589641@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Peterson wrote:
> Should network devices be allowed to contribute entropy to /dev/random?
> 
> This issue has been discussed before, but does not seem to have been
> settled: some net drivers [1] use IRQF_SAMPLE_RANDOM when calling
> request_irq(), but the vast majority do not. It seems like all net
> drivers should follow the same entropy paranoia policy (whether that
> is all net drivers should use IRQF_SAMPLE_RANDOM, no net drivers, or a
> compile-time option).


Quoting David Miller's excellent summary:


The argument is that if you have a diskless system not taking any 
keyboard or other input from the user, the network would be your only 
source of random number entropy.

But on the flip side, if the network provides the entropy, this is 
externally influencable random number entropy and thus in theory 
exploitable.  And furthermore, on-board random number generators are the 
real answer to this problem.

Thus, the impasse.

There are roughly equal arguments on both sides.  Providing some entropy 
could be argued as better than nothing, but it could also be said that 
providing potentially exploitable entropy is in fact worse than none at all.

</quote>


I tend to push people to /not/ add IRQF_SAMPLE_RANDOM to new drivers, 
but I'm not interested in going on a pogrom with existing code.  We all 
have better things to do with our time :)

	Jeff


