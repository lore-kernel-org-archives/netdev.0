From: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [RFC PATCH 0/2] mac80211: aes_ccm: cache AEAD request allocations per CPU
Date: Tue, 18 Oct 2016 15:08:31 +0100
Message-ID: <1476799713-16188-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, j@w1.fi, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org,
        Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This RFC implements per CPU caching of AEAD request structures, which allows
us to get rid of the per-packet kzalloc/kzfree calls we were forced to
introduce to deal with SG API violations, both in the mac80211 and in the
core crypto API code.

Since mac80211 only executes the AEAD transforms in softirq context, only one
AEAD request can be in flight at the same time on any given CPU, and so, instead
of free the request, we can stash its address in a per CPU variable, and reuse
it for the next packet.

This RFC only addressess CCMP, but GCM and GMAC could be fixed in the same way
(and CMAC did not suffer from the API violation issue in the first place)

Ard Biesheuvel (2):
  mac80211: aes_ccm: prepare key struct for storing context data
  mac80211: aes_ccm: cache AEAD request structures per CPU

 net/mac80211/aes_ccm.c | 80 +++++++++++++-------
 net/mac80211/aes_ccm.h | 16 ++--
 net/mac80211/key.c     | 16 ++--
 net/mac80211/key.h     |  3 +-
 net/mac80211/wpa.c     |  4 +-
 5 files changed, 71 insertions(+), 48 deletions(-)

-- 
2.7.4
