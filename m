From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next v4 0/3] net: allow setting ecn via routing table
Date: Mon,  3 Nov 2014 17:35:00 +0100
Message-ID: <1415032503-4936-1-git-send-email-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:45430 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752385AbaKCQfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 11:35:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is v4 of the patchset, its exactly the same as v3 except in patch3/3
where I added the missing 'const' qualifier to a function argument that
Eric spotted during review.

I preserved Erics Acks so that he doesn't have to resend them.

v3 cover letter:

When using syn cookies, then do not simply trust that the echoed timestamp
was not modified to make sure that ecn is not turned on magically when it
is disabled on the host.

The first two patches, which were not part of earlier series, prepare
the cookie code for the ecn route metrics change by allowing is to
more easily use the existing dst object for ecn validation.

The 3rd patch adds the ecn route metric feature support.
It is almost the same as in v2, except that we'll now also test the
dst_features when decoding a syn cookie timestamp that indicates ecn support.

These three patches then allow turning on explicit congestion notification
based on the destination network.

For example, assuming the default tcp_ecn sysctl '2', the following will
enable ecn (tcp_ecn=1 behaviour, i.e. request ecn to be enabled for a
tcp connection) for all connections to hosts inside the 192.168.2/24 network:

ip route change 192.168.2.0/24 dev eth0 features ecn

Having a more fine-grained per-route setting can be beneficial for
various reasons, for example 1) within data centers, or 2) local ISPs
may deploy ECN support for their own video/streaming services [1], etc.

Joint work with Daniel Borkmann, feature suggested by Hannes Frederic Sowa.

The patch to enable this in iproute2 will be posted shortly, it is currently
also available here:
http://git.breakpoint.cc/cgit/fw/iproute2.git/commit/?h=iproute_features&id=8843d2d8973fb81c78a7efe6d42e3a17d739003e

[1] http://www.ietf.org/proceedings/89/slides/slides-89-tsvarea-1.pdf, p.15
