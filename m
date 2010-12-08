From: Martin Willi <martin@strongswan.org>
Subject: [PATCH 0/3] xfrm: ESP Traffic Flow Confidentiality padding (v3)
Date: Wed,  8 Dec 2010 15:37:48 +0100
Message-ID: <1291819071-17538-1-git-send-email-martin@strongswan.org>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patchset adds Traffic Flow Confidentiality padding. The
first patch introduces a new Netlink XFRM attribute to configure TFC via
userspace. Patch two and three implement the padding logic in IPv4 and
IPv6 ESP. Padding is always done using the RFC4303 format an is clamped
to the PMTU.

Changes from v2:
  - Remove unused flag field in attribute, use a plain u32 as attribute payload
  - Reject installation of TFC padding on non-tunnel SAs

Martin Willi (3):
      xfrm: Add Traffic Flow Confidentiality padding XFRM attribute
      xfrm: Traffic Flow Confidentiality for IPv4 ESP
      xfrm: Traffic Flow Confidentiality for IPv6 ESP

 include/linux/xfrm.h |    1 +
 include/net/xfrm.h   |    1 +
 net/ipv4/esp4.c      |   32 ++++++++++++++++++++++++--------
 net/ipv6/esp6.c      |   32 ++++++++++++++++++++++++--------
 net/xfrm/xfrm_user.c |   19 +++++++++++++++++--
 5 files changed, 67 insertions(+), 18 deletions(-)
