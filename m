From: Nick Bowler <nbowler@elliptictech.com>
Subject: [PATCH 0/2] AH fixes for asynchronous hash algorithms.
Date: Tue,  8 Nov 2011 17:12:43 -0500
Message-ID: <1320790365-29152-1-git-send-email-nbowler@elliptictech.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here are two fixes for AH when using an asynchronous hmac driver.  Both
are -stable candidates as these problems appear to have been present
since AH was converted to use ahash way back in 2.6.33.

These code paths are not exercised when using the default software hash
implementations which do not use the ahash callbacks, but the issues can be
reproduced by using cryptd to create an asynchronous hash algorithm for
testing.

This driver could probably do with some cleanups to reduce the code
duplication (and thus test coverage) between the asynchronous callbacks
and synchronous code paths, which should help avoid these kind of
problems in the future.  These code paths apparently do not see a
lot of testing.  But that's for a later patch series.

Nick Bowler (2):
  ah: Correctly pass error codes in ahash output callback.
  ah: Read nexthdr value before overwriting it in ahash input callback.

 net/ipv4/ah4.c |    6 ++----
 net/ipv6/ah6.c |    6 ++----
 2 files changed, 4 insertions(+), 8 deletions(-)

-- 
1.7.3.4
