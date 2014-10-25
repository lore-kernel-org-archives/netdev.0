From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 0/2] net: allow setting ecn via routing table
Date: Sun, 26 Oct 2014 00:38:47 +0200
Message-ID: <1414276729-17871-1-git-send-email-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54074 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751153AbaJYWjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 18:39:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches allow turing on explicit congestion notification
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
