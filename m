From: Jeff Garzik <jeff@garzik.org>
Subject: Re: d80211 merge (was Re: [patch] d80211: use pfifo_qdisc_ops rather
 than d80211-specific qdisc)
Date: Wed, 01 Nov 2006 21:55:35 -0500
Message-ID: <45495E27.6090500@garzik.org>
References: <20061026050416.GB14199@havoc.gtf.org> <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net> <20061101112805.246e1b3b@griffin.suse.cz> <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com> <45493C09.9050707@garzik.org> <45494E51.7070707@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Simon Barber <simon@devicescape.com>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:2209 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751627AbWKBCz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 21:55:59 -0500
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <45494E51.7070707@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Ketrenos wrote:
> Jeff Garzik wrote:
>> James Ketrenos wrote:
>>> If people have issues with with specific components of d80211 prior to
>>> its merging, stand up and state what they are and how not fixing them
>>> would negatively impact people that aren't using the d80211 subsystem.
>>>
>>> Don't take the above as me saying there aren't items that need to be
>>> fixed/improved in d80211 -- there is work to be done.  But that
>>> shouldn't stop it from being merged w/ the EXPERIMENTAL flag set.
>>> We reached the point where we should be in -mm a long time ago as soon
>>> as both stacks could exist concurrently.  d80211 should have been in
>>> Linus' tree a long time ago.
>> d80211 merge stoppers:
>> - SMP issues (lack of locking, and overlocking via use of Big Network Lock)
> 
> So we can set BROKEN_ON_SMP on it and we're good.  The entire
> description of EXPERIMENTAL in init/Kconfig matches perfectly what we
> want -- bug reports, wider exposure, and a clear articulation that the
> feature is unstable.

heh, no, we don't merge stuff that's obviously incomplete or broken. 
BROKEN_ON_SMP is one step before driver death, not the first baby step 
of a driver.


>> - userspace ABI
> 
> What's the requirement on the userspace ABI?  That the existing wireless
> extension interface needs to work, or ?

The requirement is that code should not go upstream if its userspace 
interface is highly likely to change.  ABI mistakes are locked in stone 
once they hit the upstream kernel, for the most part.

As long as the userspace ABI is "baked" and generally agreed upon, then 
the requirement is satisfied.

Speaking specifically, Linus noted recently d80211 should maintain 
backwards compatibility with the WE userspace ABI, so that existing 
wireless tools keep working, and I definitely agree.  For additional 
functionality/flexibility, I presume there will be some sort of netlink 
extensible interface (cfg80211 I think?) that newer wireless tools will 
use.  In time, the WE back-compat ABI could become an optional module 
that users can disable.


> How will merging with the existing locking problems or ABI issue
> negatively impact people that aren't using the d80211 subsystem anyway?

Irrelevant.

We don't merge code with obvious bugs, especially when the justification 
is "merging means the bugs will be fixed."

If a codebase isn't getting bugs fixed as it is, that is a strong reason 
AGAINST merging it.


> If having the code there doesn't hurt anyone, why not get it out for
> wider adoption, exposure, and contribution?
> 
> Why is there such a hesitation to merge this stack and help to
> accelerate the set of functionality available with wireless on Linux?

A codebase has to have developers who will put in the minimum effort to 
make sure it is completely SMP safe, and that the ABI issues are handled 
in the way they are handled throughout the rest of the kernel.

"Wider participation" is not a blank check to merge every half-baked 
codebase out there.  One of the things that's nice about git is that 
things enter the kernel MORE baked than in the past, because distributed 
development means stuff occurs in parallel.

"Getting is upstream" is the eventual goal, NOT a magic panacea that 
wipes away existing ills.

	Jeff, who, just like you, wants to see d80211 merged




