From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 00/13] Transparent proxying patches, take two
Date: Mon, 05 Mar 2007 16:44:51 +0100
Message-ID: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:4273 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751796AbXCEPoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:44:54 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id DF3EA294020
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:44:51 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  Hi,

These patches are my second try at providing Linux 2.2-like transparent
proxying support for Linux 2.6.

Major changes since the first version:

- iptable_tproxy now does IPv4 fragment reassembly (necessary for
  processing TCP/UDP header)

- The removal of the source address check in ip_route_output() was
  incorrect.  Instead, I've implemented a separate setsockopt-settable
  per-socket flag (setting it requires CAP_NET_ADMIN) to selectively
  loosen that check in ip_route_output().

Besides these, I've tried to fix all the problems raised on netdev@ in
January.

Unfortunately the newly introduced IP_TRANSPARENT socket option leads to
a quite intrusive set of patches touching core IPv4 routing and TCP
code, however this was necessary as DaveM rejected our idea of using
IP_FREEBIND instead (and he's right, of course, as it would have caused
ABI breakage.) The current approach works by adding a new bit to the
flag field in "struct flowi".

Furthermore, I haven't removed the IPv4 routing local diversion code
(caching socket lookups in the skb) yet. Patrick recommended throwing it
out altogether and use mark-based policy routing instead, but I still
think that would be harming usability as the user would need to
harmonize the configuration in order to have two completely independent
subsystems interoperate.

-- 
 Regards,
  Krisztian Kovacs
