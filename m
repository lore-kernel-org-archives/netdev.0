From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 0/4] netfilter conntrack sysctls pernet support
Date: Tue, 10 Mar 2009 00:08:43 +0300
Message-ID: <20090309210843.GB18357@localhost>
References: <20090309181628.109019157@gmail.com> <49B56440.2010404@trash.net> <20090309190744.GA18357@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	xemul@openvz.org, adobriyan@gmail.com,
	Netfilter Development Mailinglist
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090309190744.GA18357@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Cyrill Gorcunov - Mon, Mar 09, 2009 at 10:07:44PM +0300]
...
| >> +	sn->sysctl_table[0].data = &sn->sctp_timeouts[SCTP_CONNTRACK_CLOSED];
| >> +	sn->sysctl_table[1].data = &sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT];
| >> +	sn->sysctl_table[2].data = &sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED];
| >> +	sn->sysctl_table[3].data = &sn->sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED];
| >> +	sn->sysctl_table[4].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
| >> +	sn->sysctl_table[5].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
| >> +	sn->sysctl_table[6].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
| >
| > Please use an iteration to avoid these repetitve overly long lines.
| >
| 
| Ah, thanks a lot! Indeed.
| 
| 	- Cyrill -

Patrick, if I make it like that (iterations)

	...
	BUILD_BUG_ON(ARRAY_SIZE(sctp_compat_sysctl_table) != SCTP_CONNTRACK_MAX);

	for (i = 0; i < ARRAY_SIZE(sctp_compat_sysctl_table) - 1; i++)
		sn->compat_sysctl_table[i].data = &sn->sctp_timeouts[i + 1];

	...

it seems the code become hard to follow. Yes it was long (repetitive) lines
but it was obvious what is set for every table entry and easy to find what
should be changed if SCTP_ enumeration is changed or table entry removed
(for some reason). I could make it shorter in length but remain the same
explicit assignment. How do you think?

	- Cyrill -
