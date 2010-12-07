From: Martin Willi <martin@strongswan.org>
Subject: [PATCH 0/3] xfrm: ESP Traffic Flow Confidentiality padding (v2)
Date: Tue,  7 Dec 2010 11:29:01 +0100
Message-ID: <1291717744-30111-1-git-send-email-martin@strongswan.org>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaes.ch ([213.133.111.41]:37478 "EHLO zaes.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754413Ab0LGK3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Dec 2010 05:29:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patchset adds Traffic Flow Confidentiality padding. The
first patch introduces a new Netlink XFRM attribute to configure TFC via
userspace. Patch two and three implement the padding logic in IPv4 and
IPv6 ESP. Padding is always done using the RFC4303 format an is clamped
to the PMTU.

Changes from v1:
  - Always clamp padding length to never exceed PMTU
  - Remove XFRM_TFC_PMTU flag, use USHRT_MAX padding length instead
  - Remove ESPv2 padding fallback due to the concerns from Herbert
  - Keep the existing ESP padlen field, as we don't mangle ESP padding

I've kept the currently unused flags in the XFRM attribute to implement
ESPv2 fallback or other extensions in the future without changing the ABI.

Martin Willi (3):
      xfrm: Add Traffic Flow Confidentiality padding XFRM attribute
      xfrm: Traffic Flow Confidentiality for IPv4 ESP
      xfrm: Traffic Flow Confidentiality for IPv6 ESP

 include/linux/xfrm.h |    6 ++++++
 include/net/xfrm.h   |    1 +
 net/ipv4/esp4.c      |   33 +++++++++++++++++++++++++--------
 net/ipv6/esp6.c      |   33 +++++++++++++++++++++++++--------
 net/xfrm/xfrm_user.c |   16 ++++++++++++++--
 5 files changed, 71 insertions(+), 18 deletions(-)

