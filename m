From: akpm@osdl.org
Subject: [patch 8/9] nicstar: Fix a bogus casting warning
Date: Fri, 20 Oct 2006 14:43:18 -0700
Message-ID: <200610202143.k9KLhIkV003810@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, alan@lxorguk.ukuu.org.uk,
	alan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:51332 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946457AbWJTVnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:43:47 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan@lxorguk.ukuu.org.uk>

Not enough to make Nicstar 64bit friendly but got squashed in passing so might
as well be applied

Signed-off-by: Alan Cox <alan@redhat.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/atm/nicstar.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/atm/nicstar.c~nicstar-fix-a-bogus-casting-warning drivers/atm/nicstar.c
--- a/drivers/atm/nicstar.c~nicstar-fix-a-bogus-casting-warning
+++ a/drivers/atm/nicstar.c
@@ -2759,7 +2759,7 @@ static int ns_ioctl(struct atm_dev *dev,
 {
    ns_dev *card;
    pool_levels pl;
-   int btype;
+   long btype;
    unsigned long flags;
 
    card = dev->dev_data;
@@ -2859,7 +2859,7 @@ static int ns_ioctl(struct atm_dev *dev,
       case NS_ADJBUFLEV:
          if (!capable(CAP_NET_ADMIN))
 	    return -EPERM;
-         btype = (int) arg;	/* an int is the same size as a pointer */
+         btype = (long) arg;	/* a long is the same size as a pointer or bigger */
          switch (btype)
 	 {
 	    case NS_BUFTYPE_SMALL:
_
