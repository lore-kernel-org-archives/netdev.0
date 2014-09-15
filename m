From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 04/14] tipc: add sock dump to new netlink api
Date: Mon, 15 Sep 2014 10:51:52 +0200
Message-ID: <20140915085152.GC14006@breakpoint.cc>
References: <1410424167-17427-1-git-send-email-richard.alpe@ericsson.com>
 <1410424167-17427-5-git-send-email-richard.alpe@ericsson.com>
 <20140912.171038.1165432718811920305.davem@davemloft.net>
 <54169B6C.5060709@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: Richard Alpe <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:53564 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753400AbaIOIv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 04:51:57 -0400
Content-Disposition: inline
In-Reply-To: <54169B6C.5060709@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Alpe <richard.alpe@ericsson.com> wrote:
> >You can't just say sometimes you'll partially list the set of nested
> >attributes in an object, you must public the entire object fully in
> >the netlink message or skip the object entirely.
> Ok. I bluntly assumed we could put some reassemble logic in the
> client as the end integrity should still be preserved(?).
> 
> >I would suggest that you instead size the amount of space you'll
> >need for at least the first socket being listed, and if NLMSG_GOODSIZE
> >is insufficient, allocate as much as you will actually need.
> >
> >Then you put full socket netlink blobs in there, including all nested
> >attributes, and then stop and reset back the the most recent full socket
> >published if you run out of space.
> The amount of publications a socket can have is large (~65 000). Do
> you still think this a viable solution?

I suggest to look at nf_conntrack_netlink.c ctnetlink_dump_table() and
ctnetlink_fill_info().

It should be doing something similar to what you want and it handles
the restarts correctly, i.e., cancels all partial nested attributes
on error and resumes at the beginning of said entry on the next dump.
