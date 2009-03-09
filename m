From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC 0/4] netfilter conntrack sysctls pernet support
Date: Mon, 09 Mar 2009 19:47:28 +0100
Message-ID: <49B56440.2010404@trash.net>
References: <20090309181628.109019157@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, xemul@openvz.org, adobriyan@gmail.com,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090309181628.109019157@gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First off, *please* CC netfilter-devel on patches relating to netfilter.
I've said this a hundred times in direction of the container guys
(not sure whether you specifically) and it keeps getting ignored.

Cyrill Gorcunov wrote:
> Hi here are a few patches to bring in per-net functionality
> for several conntrack protocols: DCCP, SCTP, UDPlite.
> 
> Since these protos could be built as modules I've put
> per-net operations to module init/exit routines. The change
> I would like you point the attention is that module static
> variables being marked as __read_mostly become now as dynamically
> allocated -- is it acceptable trade off?

Well, there's no other choice I guess.

> For protocols being built in (like TCP, UDP, ICMP) for which I made
> patches too but they are in a bit 'rought' state: in original
> code there some kind of reference counter to sysctl tables being
> registered (and they don't have any kind of mb, didn't check if it
> could be a problem for SMP since they are mostly __init functions)
> so I need some kind of same functionality to count per-net calls.

The tables are shared between IPv4 and IPv6, this keeps track of the
number of current users to avoid unregistering it while the AF-specific
module for either one is loaded. This would still be a global counter
with containers I think since module loading is global and they should
be visible in all containers if IPv4 or IPv6 conntrack is loaded.

> Will send RFC for these protocols soon.
> 
> So eventually I would like to hear some kind of feedback on this.
> Ideas and any kind of comments are highly appreciated.

> +	sn->sysctl_table[0].data = &sn->sctp_timeouts[SCTP_CONNTRACK_CLOSED];
> +	sn->sysctl_table[1].data = &sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT];
> +	sn->sysctl_table[2].data = &sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED];
> +	sn->sysctl_table[3].data = &sn->sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED];
> +	sn->sysctl_table[4].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
> +	sn->sysctl_table[5].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
> +	sn->sysctl_table[6].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];

Please use an iteration to avoid these repetitve overly long lines.
