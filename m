From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 20:01:38 -0400
Message-ID: <49E7C6E2.8000209@hp.com>
References: <OF5FEB5C36.3F71F1EC-ON8825759A.00785E5C-8825759A.007AEF72@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:12429 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756136AbZDQABq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 20:01:46 -0400
In-Reply-To: <OF5FEB5C36.3F71F1EC-ON8825759A.00785E5C-8825759A.007AEF72@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
> Vlad Yasevich wrote on 04/16/2009 02:19:14 PM:
> 
>> What seems to be happening though, is that there is an expectation that
>> this behavior would change with advent of IGMPv3, which adds the 
> additional
>> filtering text.  Now, we could point out that there is no normative text
>> that requires this filtering on groups, only on sources, but the 
> expectation
>> is still there.
> 
>         I have no such expectation. :-) The additional filters are 
> (already)
> applied per-socket, but existing apps not using source filters behave as
> they did before IGMPv3. That's what I'd expect.
>         The RFC you quoted for SSM applies to only the SSM address space,
> mentions this behavior explicitly as the norm for outside of that space,
> and Linux doesn't support that RFC. If it did, it would include an
> address range check as part of it.

Yes, after reading more of SSM spec, it definitely only applies to SSM
addresses that we don't support yet.  Just to clear this one item up,
I think the expectation comes from the IGMPv3 spec:

     Filtering of packets based upon a socket's multicast reception
     state is a new feature of this service interface.  The previous
     service interface [RFC1112] described no filtering based upon
     multicast join state; rather, a join on a socket simply caused the
     host to join a group on the given interface, and packets destined
     for that group could be delivered to all sockets whether they had
     joined or not.

I could be inferred from this rather vague text that in addition to source
filtering, group filters should be done.  Thus the expectation that we've
been dealing with.

That's the last I'll mention this, since most salient points have been
agreed on.

Thanks
-vlad

> 
>> I wonder how BSD and Solaris got away with it?  They both filter on 
> multicast
>> groups and source addresses.  This is not meant as rhetorical or 
> provocative,
>> just genuinely wondering.
> 
>         I think in practice, it doesn't come up much. That's why people
> seem so surprised to learn it works this way, and not the way they
> thought it did after using it, sometimes for years. But the documentation
> doesn't say a join limits what you receive on a socket, or that it
> has to be the same socket you're doing I/O on; people simply assume it.
> 
>                                                                 +-DLS
> 

