From: "David S. Miller" <davem@redhat.com>
Subject: Re: SOMAXCONN too low
Date: Wed, 29 Oct 2003 09:22:20 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031029092220.12518b68.davem@redhat.com>
References: <200310290658.h9T6w04k015302@napali.hpl.hp.com>
	<20031029133315.5638f842.ak@suse.de>
	<16287.62792.721035.910762@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davidm@napali.hpl.hp.com, ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davidm@hpl.hp.com
In-Reply-To: <16287.62792.721035.910762@napali.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Oct 2003 09:13:44 -0800
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> >>>>> On Wed, 29 Oct 2003 13:33:15 +0100, Andi Kleen <ak@suse.de> said:
> 
>   Andi> Another alternative would be to make it a fraction of the
>   Andi> listen() argument per socket
>   Andi> (e.g. min(tcp_max_syn_backlog,min(128,10%*listenarg))) to
>   Andi> allow the application to easily change it.
> 
> I don't understand what purpose this would serve.  Seems to me it
> would make life only more complicated for apps that know what they're
> doing.

Andi's saying the the max backlog should be a function of
the queue length the user asks for when he makes the listen()
system call.

Also note that we'll need to tweak the TCP listening socket SYNQ hash
table size if we modify these kinds of things.

> At the moment, in-kernel servers are at an unfair advantage over
> user-space servers for this reason.

I totally disagree, the only reason things like TuX perform better
than their userland counterparts and don't run into SOMAXCONN issues
is because it is threaded properly.  This is where all of the "jitter"
stuff you keep talking about really comes from.

When I've asked in the past to see code for userland servers that have
a problem wrt. SOMAXCONN, it's always the case that the userland
server only lets one of it's threads take new connections via
accept().  It's no wonder they have problems....

This is why I'm usually big time against changing this value, if we
change it we may be less likely to discover userland server stupidity
like that I mentioned above.
