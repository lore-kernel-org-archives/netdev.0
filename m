From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 0/2] Disable forwarding of LRO skbs [2nd try]
Date: Thu, 19 Jun 2008 19:06:01 +0100
Message-ID: <20080619180600.GS5350@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Kieran Mansley <kmansley@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.mbr-roch.zen.net.uk ([212.23.3.140]:44827 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752027AbYFSSGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 14:06:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Large Receive Offload (LRO) destroys packet headers that should be
preserved when forwarding.  Currently it also triggers a BUG() or WARN()
in skb_gso_segment().  We should disable it wherever forwarding is
enabled, and discard LRO skbs with a warning if it is turned back on.

Since the previous version of these patches, I have:
- Tightened the test for LRO'd skbs, so it should not catch skbs from
  VM guests that want GSO
- Made the test an inline function, with the warning a separate extern
  function
- Rebased against net-next-2.6

Ben.

Ben Hutchings (2):
  net: Disable LRO on devices that are forwarding
  net: Discard and warn about LRO'd skbs received for forwarding

 include/linux/netdevice.h |    1 +
 include/linux/skbuff.h    |   14 ++++++++++++++
 net/bridge/br_forward.c   |    2 +-
 net/bridge/br_if.c        |    1 +
 net/core/dev.c            |   24 ++++++++++++++++++++++++
 net/core/skbuff.c         |    8 ++++++++
 net/ipv4/devinet.c        |   21 ++++++++++++++++-----
 net/ipv4/ip_forward.c     |    3 +++
 net/ipv6/addrconf.c       |    6 ++++++
 net/ipv6/ip6_output.c     |    3 +++
 10 files changed, 77 insertions(+), 6 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
