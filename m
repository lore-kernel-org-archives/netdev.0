From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC 3/7] netfilter: add NF_INET_LOCAL_SOCKET_IN chain type
Date: Tue, 29 Sep 2015 23:19:59 +0200
Message-ID: <20150929211959.GF19923@breakpoint.cc>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
 <1443525140-13493-4-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, daniel@iogearbox.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	fw@strlen.de, balazs.scheidler@balabit.com
To: Daniel Mack <daniel@zonque.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443525140-13493-4-git-send-email-daniel@zonque.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Mack <daniel@zonque.org> wrote:
> Add a new chain type NF_INET_LOCAL_SOCKET_IN which is ran after the
> input demux is complete and the final destination socket (if any)
> has been determined.
> 
> This helps filtering packets based on information stored in the
> destination socket, such as cgroup controller supplied net class IDs.

This still seems like the 'x y' problem ("want to do X, think Y is
correct solution; ask about Y, but thats a strange thing to do").

There is nothing that this offers over INPUT *except* that sk is
available.  But there is zero benefit as far as I am concerned --
why would you want to do any meaningful filtering based on the sk at
that point...?

Drop?  Makes no sense, else application would not be running in the first
place.
Allowing response packets?  Can already do that with conntrack.

So the only 'benefit' is that netcls id is available; but
a) why is that even needed and
b) is such a huge sledgehammer just for net cgroup accounting
worth it?

Another question is what other strange things come up once we would
open this door.

> listening on a specific task, the resulting error code that is sent
> back to the remote peer can't be controlled with rules in
> NF_INET_LOCAL_SOCKET_IN chains.

Right, and that makes this even weirder.

For deterministic ingress filtering you can only rely on what
is contained in the packet.
