From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity
 protection
Date: Thu, 12 Dec 2013 06:34:24 -0800
Message-ID: <1386858864.19078.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52A75EF8.3010308@in.tum.de>
	 <20131211.150137.368953964178408437.davem@davemloft.net>
	 <52A8C8B4.4060109@in.tum.de>
	 <20131211122637.75b09074@nehalam.linuxnetplumber.net>
	 <87bo0nulkt.fsf@tassilo.jf.intel.com> <52A8ECF5.3070604@in.tum.de>
	 <20131212012317.GL21717@two.firstfloor.org>
	 <52A98DBF.4090702@appelbaum.net> <52A9A17F.6050505@in.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jacob Appelbaum <jacob@appelbaum.net>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, knock@gnunet.org
To: Christian Grothoff <grothoff@in.tum.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:55762 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab3LLOe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 09:34:27 -0500
In-Reply-To: <52A9A17F.6050505@in.tum.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-12 at 12:43 +0100, Christian Grothoff wrote:
> On 12/12/2013 11:19 AM, Jacob Appelbaum wrote:
> > I think that generally, I would prefer if the code didn't use MD5 but
> > otherwise, I don't see any real risk of adding an exploitable hole. It
> > seems silly to disable it by default though - ideally, I'd like a sysctl
> > to ensure that Tor could use this without making the user recompile
> > their kernel. That is more of a pain than running a userspace helper, I
> > think.
> > 
> > All the best,
> > Jacob
> 
> Given that the output is truncated to 32 bits and that performance (SYN
> flood) is also a concern, AND that the original TCP SQN generation is
> also MD5-based (and we want to look the same), what disadvantage do you
> see over MD5?  Given the truncation to 32 bits, I don't think a stronger
> hash would do anything for us.
> 
> As for it being disabled by default, we did this with respect to
> kernel submission guidelines which we understood said that features
> should _initially_ always be submitted with disabled-by-default
> (presumably so that until they have stabilized, nobody is harmed
> unless they explicitly activate the code).
> 
> I don't see the point in having a sysctl, as applications have to
> explicitly request it anyway.

Wait a minute.

Your implementation looks like another TCP MD5 thing, but with a single
secret. Check at git history to discover how many bugs we had to fix.
Ask yourself how wrong was TCP MD5 being implemented in the kernel.

Very soon you'll need to support different secrets. You do not want all
clients share a common secret, do you ? How can a server change its
secret without disrupting clients ?

How having a constant initial sequence number can even be valid ?
What about TCP timestamps being not available at all ?
How typical servers can be behind a load balancer ?
Or am I missing something ?

With various proposals (like TCP minion), maybe its time to be able to
implement part of TCP stack in user land (Keep the mux inside the
kernel, and forward raw incoming packets to user land where all the
crazy things can be done without kernel patching.)

To me your idea is very close from TCP fast open. The only difference
would be for the server to not send its cookie in SYNACK ?

Sorry, you seem to hurry to get this facility, I do not see how it can
really save the world. If it does, you definitely should get feedback
from TCP community at IETF.

Thanks
