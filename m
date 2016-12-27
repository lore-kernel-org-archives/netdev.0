From: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Subject: [PATCH 0/2] ath9k: kill of ACCESS_ONCE() in MAC drivers
Date: Tue, 27 Dec 2016 18:49:57 +0000
Message-ID: <1482864599-19995-1-git-send-email-mark.rutland@arm.com>
Cc: ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

For several reasons, it would be beneficial to kill off ACCESS_ONCE()
tree-wide, in favour of {READ,WRITE}_ONCE(). These work with aggregate
types, more obviously document their intended behaviour, and are
necessary for tools like KTSAN to work correctly (as otherwise reads and
writes cannot be instrumented separately).

While it's possible to script a tree-wide conversion using Coccinelle,
some cases such as the ath9k MAC drivers require some manual
intervention to ensure that the resulting code remains legible. This
series moves the ath9k MAC drivers over to {READ,WRITE}_ONCE(). In both
cases this is functionally equivalent to the below Coccinelle script
being applied, though the existing formatting is retained.

----
virtual patch

@ depends on patch @
expression E1, E2;
@@

- ACCESS_ONCE(E1) = E2
+ WRITE_ONCE(E1, E2)

@ depends on patch @
expression E;
@@

- ACCESS_ONCE(E)
+ READ_ONCE(E)
----

Thanks,
Mark.

Mark Rutland (2):
  ath9k: ar9002_mac: kill off ACCESS_ONCE()
  ath9k: ar9003_mac: kill off ACCESS_ONCE()

 drivers/net/wireless/ath/ath9k/ar9002_mac.c | 64 ++++++++++----------
 drivers/net/wireless/ath/ath9k/ar9003_mac.c | 92 ++++++++++++++---------------
 2 files changed, 78 insertions(+), 78 deletions(-)

-- 
2.7.4
