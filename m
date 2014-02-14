From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V2 net-next 0/5] xen-net{back,front}: Multiple transmit
 and receive queues
Date: Fri, 14 Feb 2014 15:52:36 +0000
Message-ID: <20140214155236.GF18398@zion.uk.xensource.com>
References: <1392378624-6123-1-git-send-email-andrew.bennieston@citrix.com>
 <20140214140635.GA18398@zion.uk.xensource.com>
 <52FE2DFC.8050702@citrix.com>
 <20140214152539.GD18398@zion.uk.xensource.com>
 <52FE390B.3020102@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<ian.campbell@citrix.com>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>
To: Andrew Bennieston <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:4546 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752680AbaBNPwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 10:52:39 -0500
Content-Disposition: inline
In-Reply-To: <52FE390B.3020102@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 03:40:59PM +0000, Andrew Bennieston wrote:
[...]
> >Wei.
> 
> Let me attempt to clear this up. Bear with me...
> 
> Queue selection is a decision by a transmitting system about which
> queue it uses for a particular packet. A well-behaved receiving
> system will pick up packets on any queue and throw them up into its
> network stack as normal. In this manner, the details of queue
> selection don't matter from the point of view of a receiving guest
> (either frontend or backend). That is; if a "malicious" frontend
> sends all of its packets on a single queue, then it is only damaging
> itself - by reducing its effective throughput to that of a single
> queue. This will not cause a problem to the backend. The same goes
> for the "select a random queue" scenario, although here you probably
> shouldn't expect decent TCP performance. Certainly there will be no
> badness in terms of affecting the backend or other systems, beyond
> that which a guest could achieve with a broken TCP stack anyway.
> 

Cool, this is much clearer about this feature and what I want to know.
In a word, there's no coupling what's so ever when frontend / backend
select which algorithm to use. Then there's nothing to fix. Thank you
for being patient to explain it to a dumb guy. :-)

> In light of this, algorithm selection is (mostly) a function of the
> transmitting side. The receiving side should be prepared to receive
> packets on any of the legitimately established queues. It just
> happens that the Linux netback and Linux netfront both use
> skb_get_hash() to determine this value.
> 

I somehow had the impression that two ends need to use the same
algorithm. They just happen to be using the same algorithm in the
current implementation. I understand now.

> In the future, some frontends (i.e. Windows) may need to do complex
> things like pushing hash state to the backend. This will be taken
> care of with extensions to the protocol at the point these are
> implemented.
> 

As long as this doesn't break that "no coupling" condition it is fine.

Wei.

> Andrew.
> 
> >
> >>Andrew.
> >>>
> >>>I don't see relevant code in this series to handle "rogue other end". I
> >>>presume for a simple hash algorithm like L4 is not very important (say,
> >>>even a packet ends up in the wrong queue we can still safely process
> >>>it), or core driver can deal with this all by itself (dropping)?
> >>>
> >>>Wei.
> >>>
