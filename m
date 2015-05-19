From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH -next] net: preserve geometry of fragment sizes when forwarding
Date: Tue, 19 May 2015 12:34:12 -0700
Message-ID: <6079.1432064052@nyx>
References: <20150518204049.GC20709@breakpoint.cc> <20150518.165550.359134808190719687.davem@davemloft.net> <20150518213329.GA2335@breakpoint.cc> <20150518.195105.2072041210798369557.davem@davemloft.net> <20150519123415.GC5063@breakpoint.cc>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hannes@stressinduktion.org, edumazet@google.com,
	herbert@gondor.apana.org.au
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:39926 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbbESTeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 15:34:25 -0400
In-reply-to: <20150519123415.GC5063@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de> wrote:
[...]
> cons: doesn't resolve hypothetical(?) router edge cases:
>   #1. if we'd receive e.g. fragment size 1000 and fragment size
>   200, where both fragments have DF bit set, we will currently
>   send a single 1200 byte DF packet, if outdevice has mtu >= 1200.
>
>   This is because ip_finish_output() only fragments if skb->len > mtu.
>
>   #2 iff we do refragment (e.g. out mtu is 1000), we re-create fragments
>   of size 1000 and 200, but DF bit gets lost in the process.
>
>Neither seems to be a big problem, #2 doesn't break end-to-end connectivity,
>and #1 doesn't seem to happen in practice; else we should have seen
>bug reports by now.  However, I do feel uneasy about it and think we should
>fix it.

	FWIW, I've seen Openstack-based network topologies with local
customizations to take advantage of #1 to deliberately avoid
refragmentation on bridge egress.  In this case, the bridge egress port
is a veth device, and the bridge-side veth mtu is set higher than the
veth peer's mtu, which is in a container.  The veth driver does not
check mtu on transmit, so this "works."

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
