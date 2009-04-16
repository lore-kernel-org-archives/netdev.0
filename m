From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 16:30:39 -0700
Message-ID: <20090416163039.33d5eeed@nehalam>
References: <49E7A0D2.60504@hp.com>
	<OF5FEB5C36.3F71F1EC-ON8825759A.00785E5C-8825759A.007AEF72@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34611 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756297AbZDPXap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 19:30:45 -0400
In-Reply-To: <OF5FEB5C36.3F71F1EC-ON8825759A.00785E5C-8825759A.007AEF72@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009 15:22:49 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> Vlad Yasevich wrote on 04/16/2009 02:19:14 PM:
> 
> > What seems to be happening though, is that there is an expectation that
> > this behavior would change with advent of IGMPv3, which adds the 
> additional
> > filtering text.  Now, we could point out that there is no normative text
> > that requires this filtering on groups, only on sources, but the 
> expectation
> > is still there.
> 
>         I have no such expectation. :-) The additional filters are 
> (already)
> applied per-socket, but existing apps not using source filters behave as
> they did before IGMPv3. That's what I'd expect.
>         The RFC you quoted for SSM applies to only the SSM address space,
> mentions this behavior explicitly as the norm for outside of that space,
> and Linux doesn't support that RFC. If it did, it would include an
> address range check as part of it.
> 
> > I wonder how BSD and Solaris got away with it?  They both filter on 
> multicast
> > groups and source addresses.  This is not meant as rhetorical or 
> provocative,
> > just genuinely wondering.
> 
>         I think in practice, it doesn't come up much. That's why people
> seem so surprised to learn it works this way, and not the way they
> thought it did after using it, sometimes for years. But the documentation
> doesn't say a join limits what you receive on a socket, or that it
> has to be the same socket you're doing I/O on; people simply assume it.
> 
>                                                                 +-DLS

You could always use packet/socket filter to keep the packets from
coming out to user space.
