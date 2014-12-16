From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Tue, 16 Dec 2014 23:50:49 +0100
Message-ID: <1418770249.3446250.203741129.5333330E@webmail.messagingengine.com>
References: <1418659395.9773.13.camel@edumazet-glaptop2.roam.corp.google.com>
 <548F0F62.7080704@fb.com> <5490B4EF.1030803@akamai.com>
 <20141216.174524.888376617592272638.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jbacik@fb.com, eric.dumazet@gmail.com,
	alexei.starovoitov@gmail.com, chavey@google.com, ycheng@google.com,
	kafai@fb.com, netdev@vger.kernel.org, rostedt@goodmis.org,
	brakmo@fb.com, Kernel-team@fb.com,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>
To: David Miller <davem@davemloft.net>, jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:59705 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751130AbaLPWux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 17:50:53 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 55D2A20CA1
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 17:50:50 -0500 (EST)
In-Reply-To: <20141216.174524.888376617592272638.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 16, 2014, at 23:45, David Miller wrote:
> From: Jason Baron <jbaron@akamai.com>
> Date: Tue, 16 Dec 2014 17:40:47 -0500
> 
> > We are interested in tcp tracing as well. Another requirement that
> > we have that I don't think I saw is the ability to start/stop
> > tracing on sockets (potentially multiple times) during the lifetime
> > of a connection. So for example, the ability to use setsockopt(), to
> > selectively start/stop tracing on a connection, so as not to incur
> > overhead for non-traced sockets.
> 
> This is so backwards.
> 
> You make the tracing cheap enough that this can never be an issue.
> 
> Your requirement can only exist if the implementation is broken
> by design.

An idea I had was to add a proxy tcp congestion control which could be
selectively chosen per destination as soon as Daniel's patchset hits
net-next or one could enable it globally by
sys/net/ipv4/tcp_congestion_control. Needed tracepoints could be
installed in the congestion_ops handlers and the additional storage
could live inside the private data of the congestion control handler.
Further callbacks could go to a chained congestion control handler. The
names could be extended like "t:cubic", t for tracing.

Do the congestion control callbacks provide enough insight to the
connection state?

Bye,
Hannes
