From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] wext: handle NULL exta data in iwe_stream_add_point better
Date: Wed, 11 Jan 2017 21:39:07 +0100
Message-ID: <3292373.oxnXTOSWCQ@wuerfel>
References: <20170111143532.485827-1-arnd@arndb.de> <CAK8P3a2mOT=BG=9yxJ1e-q__5FYq6dfF3t3bT1vqcgFaQAUjog@mail.gmail.com> <1484147177.29931.14.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-wireless@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484147177.29931.14.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, January 11, 2017 4:06:17 PM CET Johannes Berg wrote:
> 
> Applied. Also fixed the typo in the subject :)

Thanks! Unfortunately I now got another warning for the same function,
and though I would have expected the patch to fix it, that did not work:

In file included from /git/arm-soc/drivers/net/wireless/intersil/prism54/islpci_dev.h:27:0,
                 from /git/arm-soc/drivers/net/wireless/intersil/prism54/isl_ioctl.h:24,
                 from /git/arm-soc/drivers/net/wireless/intersil/prism54/isl_ioctl.c:32:
/git/arm-soc/drivers/net/wireless/intersil/prism54/isl_ioctl.c: In function 'prism54_get_scan':
/git/arm-soc/include/net/iw_handler.h:560:4: error: argument 2 null where non-null expected [-Werror=nonnull]
    memcpy(stream + point_len, extra, iwe->u.data.length);

The change below kills that warning too, but it gets even uglier there:

diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index 1a41043688bc..c2aa73e5e6bb 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -556,7 +556,7 @@ iwe_stream_add_point(struct iw_request_info *info, char *stream, char *ends,
 		memcpy(stream + lcp_len,
 		       ((char *) &iwe->u) + IW_EV_POINT_OFF,
 		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
-		if (iwe->u.data.length)
+		if (iwe->u.data.length && extra)
 			memcpy(stream + point_len, extra, iwe->u.data.length);
 		stream += event_len;
 	}

Let me know if you want a proper follow-up patch, or if you can amend your
commit, or you have a better idea for resolving that warning.

	Arnd
