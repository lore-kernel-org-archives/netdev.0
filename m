From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] ARCH: Fix 32-bit x86 MSI-X allocation leakage
Date: Mon, 28 Apr 2008 14:27:40 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904F9ED35@orsmsx414.amr.corp.intel.com>
References: <20080426005850.7098.77479.stgit@scrappy.jf.intel.com> <200804281909.m3SJ9v0k015496@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <torvalds@linux-foundation.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15045 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934594AbYD1V1i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 17:27:38 -0400
Content-class: urn:content-classes:message
In-Reply-To: <200804281909.m3SJ9v0k015496@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Thanks Jesse for forwarding this to me.

Yes, Jesse took care of that oversight for me.  I owe him a tasty
beverage.  :-)

> The patch below does looks ok in terms of fixing the issue 
> with respect to MSIs.
> 
> Unfortunately the entire used_vectors concept appears broken. 
>  Rusty is not taking vector_lock.  used_vectors as designed 
> can not work on x86_64 as vectors are allocated to interrupts 
> in a per cpu manner, resulting in unnecessary divergences 
> between the two pieces of code.  used_vectors is an an extra 
> data structure that we have to keep in sync, and failing to 
> keep that data structure in sync is why we have a problem.
> 
> For the concept of allocating a non 0x80 vector for 
> interrupts Rusty was on the right track.  His implementation 
> just appears to be broken in the corner cases, and has a 
> design we can not use long term.
> 
> To fix this my inclination is to revert:
> dbeb2be21d678c49a8d8bbf774903df15dd55474 (the infracture) and 
> c18acd73ffc209def08003a1927473096f66c5ad (the lguest user) as 
> we need to rework those pieces of code anyway, and then work 
> with Rusty to come up with something that we can share on x86 
> and x86_64.

Either way, I'm fine if that gets reverted or not, just as long as we
don't revert back to leaking vectors on device unload.  But if things
are somewhat functional today, I'd say leave the code in there until the
proper solution can be worked out.  Then go ahead and pull it out and
put the new bits in, so anyone currently using the functionality
provided isn't left out in the cold.  That is assuming that these bits
are being used...

Cheers,
-PJ Waskiewicz
