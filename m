From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v2 1/3] gre: do not assign header_ops in collect
 metadata mode
Date: Tue, 26 Apr 2016 10:39:32 +0200
Message-ID: <20160426103933.0c79a21b@griffin>
References: <cover.1461495411.git.jbenc@redhat.com>
	<bd50f4691e9edc28c5a9ec861863f7f6cf316077.1461495411.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41838 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507AbcDZIjh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 04:39:37 -0400
In-Reply-To: <bd50f4691e9edc28c5a9ec861863f7f6cf316077.1461495411.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 24 Apr 2016 13:00:20 +0200, Jiri Benc wrote:
> In ipgre mode (i.e. not gretap) with collect metadata flag set, the tunnel
> is incorrectly assumed to be mGRE in NBMA mode (see commit 6a5f44d7a048c).
> This is not the case, we're controlling the encapsulation addresses by
> lwtunnel metadata. And anyway, assigning dev->header_ops in collect metadata
> mode does not make sense.
> 
> Similarly, when a multicast remote IP address is set together with the
> collect metadata flag, the processing described above would happen, too. As
> there's not much sense in specifying remote/local IP address for lwtunnels,
> reject such configuration.
> 
> v2: Reject configuration specifying both remote/local address and collect
>     metadata flag.

Thinking about this more, this *is* uAPI breakage and we can't do that.
It affects also gretap and current users of gretap lwtunnels would be
broken. This is even more likely as it's not possible to create gretap
lwtunnel using iproute2 without specifying a fake remote address.

In theory, we could wrap the current ipgre_tunnel_validate with a new
function that would be set as ipgre_link_ops->validate but that would
add unnecessary complexity and would make ipgre and gretap behavior
different.

I'm sorry, we have to live with what we have. This should have been
taken into account when you implemented lwtunnels for GRE, we can't
change this now, it's too late.

I'll send v3 with this patch being restored to exactly what I had in v1.

 Jiri
