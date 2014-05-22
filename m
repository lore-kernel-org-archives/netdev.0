From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the
 permisions of netlink messages
Date: Thu, 22 May 2014 17:05:05 +0200
Message-ID: <20140522170505.64ef87a2@griffin>
References: <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org>
	<536AB151.2070804@dti2.net>
	<CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
	<20140507.185256.496391962242529591.davem@davemloft.net>
	<CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
	<CA+55aFzZg3LfpPpx3+83sB0npd9863NTMqvsCArMDjg-9J151A@mail.gmail.com>
	<CALCETrVWkW16Y7hOq-mA1auJjRXmwiAUfAGurK0-2bOdbZu_dA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Vivek Goyal <vgoyal@redhat.com>,
	Simo Sorce <ssorce@redhat.com>,
	"security@kernel.org" <security@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59854 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418AbaEVPFV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 11:05:21 -0400
In-Reply-To: <CALCETrVWkW16Y7hOq-mA1auJjRXmwiAUfAGurK0-2bOdbZu_dA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 May 2014 16:45:10 -0700, Andy Lutomirski wrote:
> It looks like Zebra is mucking with its effective set.  It creates the
> socket w/o effective caps, raises them to bind (no clue why), lowers
> them post-bind, then raises them again to sendto.  Presumably the new
> checks cause the sendto to fail b/c the socket()-time credentials were
> insufficient.
> 
> I don't see why it bound w/ elevated permissions, since I don't think
> this is important.  And it never connected at all.
> 
> Hence my suggestion that we check permissions at connect time instead
> of socket() time and that we just check send-time permissions on an
> unconnected socket.  Yes, this is awful.

AFAIK this is still unresolved and this seems to be the only solution
proposed so far that fixes the security problem and does not break
zebra. Or have I missed something and the conclusion is zebra needs to
be modified to comply with the changed semantics?

 Jiri

-- 
Jiri Benc
