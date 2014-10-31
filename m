From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next v2 0/2] net: allow setting ecn via routing table
Date: Fri, 31 Oct 2014 13:13:20 +0100
Message-ID: <1414757602-27637-1-git-send-email-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40919 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758257AbaJaMNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 08:13:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is the resend of the v1 patchset, as requested.
Thanks again for all the valuable comments and the feedback received for
the original submission.

I did a quick re-test, with a 'feature ecn' route ecn set and tcp_ecn != 1
and the various combinations look ok:

host with ecnroute is initiator
- connect to host with tcp_ecn != 0: connection uses ecn
- connect to host with tcp_ecn == 0: ecn is announced but not used

host with ecnroute is responder:
- connect from host with tcp_ecn == 1: connection uses ecn
- connect from host with tcp_ecn != 1: connection does not uses ecn

original cover letter below:

These two patches allow turning on explicit congestion notification
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
