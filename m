From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] zd1211rw: Removed unneeded packed attributes
Date: Wed, 30 Aug 2006 15:06:03 +0200
Message-ID: <200608301506.03296.mb@bu3sch.de>
References: <20060829225143.AD4637B40A0@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org, kune@deine-taler.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:7618
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750988AbWH3NHQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 09:07:16 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20060829225143.AD4637B40A0@zog.reactivated.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 30 August 2006 00:51, Daniel Drake wrote:
> From: Ulrich Kunitz <kune@deine-taler.de>
> 
> Inspired by an e-mail by Stephen Hemminger I decided to remove all
> unneeded packed attributes from the code where the member variables are
> already aligned. This avoids horrible code being generated on some
> architectures.
> 
> Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
> Signed-off-by: Daniel Drake <dsd@gentoo.org>
> ---
>  zd_ieee80211.h |    2 +-
>  zd_mac.c       |    2 +-
>  zd_mac.h       |    4 ++--
>  zd_usb.h       |   14 +++++++-------
>  4 files changed, 11 insertions(+), 11 deletions(-)
> 
> Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_ieee80211.h
> ===================================================================
> --- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_ieee80211.h
> +++ linux-2.6/drivers/net/wireless/zd1211rw/zd_ieee80211.h
> @@ -64,7 +64,7 @@ struct cck_plcp_header {
>  	u8 service;
>  	__le16 length;
>  	__le16 crc16;
> -} __attribute__((packed));
> +};

Because this clearly is a workaround for broken compilers to me,
I would rather do the following:

--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_ieee80211.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_ieee80211.h
@@ -64,7 +64,7 @@ struct cck_plcp_header {
 	u8 service;
 	__le16 length;
 	__le16 crc16;
-} __attribute__((packed));
+} /* __attribute__((packed)) */;


This way it's still clear to the reader, that these structs
must be packed and are most likely for communication with
the hardware.

-- 
Greetings Michael.
