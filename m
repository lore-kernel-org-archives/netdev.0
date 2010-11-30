From: Martin Willi <martin@strongswan.org>
Subject: [PATCH 0/5] xfrm: ESP Traffic Flow Confidentiality padding
Date: Tue, 30 Nov 2010 16:49:10 +0100
Message-ID: <1291132155-31277-1-git-send-email-martin@strongswan.org>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patchset adds Traffic Flow Confidentiality padding. The
first patch introduces a new Netlink XFRM attribute to configure TFC via
userspace. The second patch removes an existing padlen option in ESP; It
is not used at all, and I currently don't see the purpose of the field,
nor how it should interact with TFC padding enabled. Patch three and four
implement the padding logic in IPv4 and IPv6 ESP.

Padding is specified with a length to pad the encapsulated data to.
Support for TFC padding as specified in RFC4303 must be negotiated
explicitly by the key management protocol, hence the optional flag. The
fallback with ESP padding field expansion is limited to 255 padding
bytes. If this is insufficient, padding length is randomized to hide
the real length as good as possible.

The last patch adds an option to pad all packets to the PMTU. It works
fine for simple scenarios, but I'm not sure if my PMTU lookup works in
all cases (nested transforms?). Any pointer would be appreciated.

Martin Willi (5):
      xfrm: Add Traffic Flow Confidentiality padding XFRM attribute
      xfrm: Remove unused ESP padlen field
      xfrm: Traffic Flow Confidentiality for IPv4 ESP
      xfrm: Traffic Flow Confidentiality for IPv6 ESP
      xfrm: Add TFC padding option to automatically pad to PMTU

 include/linux/xfrm.h |    8 +++++++
 include/net/esp.h    |    3 --
 include/net/xfrm.h   |    1 +
 net/ipv4/esp4.c      |   58 +++++++++++++++++++++++++++++++++++--------------
 net/ipv6/esp6.c      |   58 +++++++++++++++++++++++++++++++++++--------------
 net/xfrm/xfrm_user.c |   16 ++++++++++++-
 6 files changed, 105 insertions(+), 39 deletions(-)
