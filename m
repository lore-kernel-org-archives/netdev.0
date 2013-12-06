From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 0/5] pktgen IPsec support
Date: Fri, 6 Dec 2013 17:53:29 +0800
Message-ID: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:55563 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756818Ab3LFJxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 04:53:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Dave/Steffen

Current pktgen IPsec supports only transport/ESP combinnation,
and it's buggy before I fixed transformed IP header/length issue
a few days ago.

This patchset enables user to do almost any IPsec transformation,
both transport/tunnel mode, and AH/ESP/IPcomp type.

Below configuration has been tested, and using Wireshark could decrypt
out plain text in good formation without any checksum/auth errors:

Mode/TYPE	AH	ESP
Transport	x	x
Tunnel		x	x

ChangeLog
v2:
  Rebase patchset against newest net-next.
  Patch1: Remove adding rebundant empty line spotted by Sergei.
  Patch2: Use only one dst pointing into itself to save space.

Fan Du (5):
  {pktgen, xfrm} Remove original pktgen ipsec fixed configuration
  {pktgen, xfrm} Using "pgset spi xxx" to spedifiy SA for a given flow
  {pktgen, xfrm} Construct skb dst for tunnel mode transformation
  {pktgen, xfrm} Introduce xfrm_state_lookup_byspi for pktgen
  {pktgen, xfrm} Correct xfrm state lock usage when transforming

 include/net/xfrm.h    |    7 ++-----
 net/core/pktgen.c     |   55 +++++++++++++++++++++++++++++++++----------------
 net/xfrm/xfrm_state.c |   43 +++++++++++++++-----------------------
 3 files changed, 56 insertions(+), 49 deletions(-)

-- 
1.7.9.5
