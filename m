From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 17:19:14 -0400
Message-ID: <49E7A0D2.60504@hp.com>
References: <OF0F292ED0.17C084A6-ON8825759A.00718BFC-8825759A.00730FD8@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:9952 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbZDPVTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 17:19:18 -0400
In-Reply-To: <OF0F292ED0.17C084A6-ON8825759A.00718BFC-8825759A.00730FD8@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
>> Well guess then we need the global proc setting after all. With the
>> current misbehavior as a default applications need to be rebuilt and
> 
>         The current behavior, as either your or Vlad's RFC quotes pointed
> out as easily as the history to go with it, is exactly the expected behavior
> for decades. I think it is not misbehavior so much as your misconception,
> though a common one.
> 

What seems to be happening though, is that there is an expectation that
this behavior would change with advent of IGMPv3, which adds the additional
filtering text.  Now, we could point out that there is no normative text
that requires this filtering on groups, only on sources, but the expectation
is still there.

>> source code that is running on multiple OSes now would have to  customized
>> to special case for Linux.
> 
>         No, actually. If you write it for the current behavior, it'll work
> fine on an OS like Solaris that has departed from the original socket
> behavior. If you're sloppy and don't handle unexpected traffic, it'll be
> wrong on both-- you just won't know it until someone runs something with
> the same port and multicast address on your network and wrecks your app.

I'd have to reluctantly agree here.  Any application that expects original
multicast behavior will be broken by a system-wide change.  I think existing
applications have already figured out all the workarounds they need.

> 
>> So add a global proc setting to determine the initial setting of 
> IP_MULTICAST_ALL?
> 
>         This breaks unknown existing applications that are correctly
> written. I think it's clearly wrong to change the behavior of someone
> else's socket to match your idea of how it should've been done 25 years
> too late. An option that enables new behavior for your own socket, which
> must be a new app, is fine. Adding a socket option as part of a port
> is no great hurdle, and I'm guessing you aren't trying to run a Solaris
> binary on Linux. So what's the problem?
> 
>                                                                 +-DLS

I wonder how BSD and Solaris got away with it?  They both filter on multicast
groups and source addresses.  This is not meant as rhetorical or provocative,
just genuinely wondering.

-vlad
