From: Florian Westphal <fw@strlen.de>
Subject: Re: [patch net-next] doc: add nf_conntrack sysctl api documentation
Date: Wed, 16 Jan 2013 14:26:24 +0100
Message-ID: <20130116132624.GD3484@breakpoint.cc>
References: <1358340257-1902-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, rob@landley.net,
	linux-doc@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358340257-1902-1-git-send-email-jiri@resnulli.us>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Pirko <jiri@resnulli.us> wrote:
> I grepped through the code and picked bits about nf_conntrack sysctl api
> and put that into one documentation file.

Thanks a lot for doing this.  A few comments/suggestions below.

> +nf_conntrack_checksum - BOOLEAN
> +	0 - disabled
> +	not 0 - enabled (default)
> +
> +	Enable connection tracking checksuming.

Verify checksum of incoming packets.  Packets with bad checksum
will not be considered for connection tracking, i.e. such packets
will be in INVALID state.

> +nf_conntrack_events - BOOLEAN
> +	0 - disabled
> +	not 0 - enabled (default)
> +
> +	If this option is enabled, the connection tracking code will provide
> +	a notifier chain that can be used by other kernel code to get notified
> +	about changes in the connection tracking state.

If this option is enabled, the connection tracking code will
provide userspace with connection tracking events via ctnetlink.

[ The notifier call chain doesn't exist any more (ctnetlink was
the only user). ]

> +nf_conntrack_events_retry_timeout - INTEGER (seconds)
> +	default 15
> +
> +	Timeout after which destroy event will be delivered.

This option is only relevant when "reliable connection tracking
events" are used.  Normally, ctnetlink is "lossy", i.e. when
userspace listeners can't keep up, events are dropped.

Userspace can request "reliable event mode".  When this mode is
active, the conntrack will only be destroyed after the event was
delivered.  If event delivery fails, the kernel periodically
re-tries to send the event to userspace.

This is the maximum interval the kernel should use when re-trying
to deliver the destroy event.

Higher number means less delivery re-tries (but it will then take
longer for a backlog to be processed).

> +nf_conntrack_log_invalid - INTEGER
> +	0 - disabled (default)
> +	IPPROTO_RAW (log packets of any proto)
> +	IPPROTO_TCP
> +	IPPROTO_ICMP
> +	IPPROTO_ICMPV6
> +	IPPROTO_DCCP
> +	IPPROTO_UDP
> +	IPPROTO_UDPLITE
> +
> +	For values, see <linux/in.h>
> +
> +	Log invalid packets of a type specified by value.

I would write the numbers here, e.g:

Log invalid packets of a type specified by protocol number.
255 - log packets of any protocol
6 - log tcp
...
