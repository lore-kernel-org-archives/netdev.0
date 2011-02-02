From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] iproute2: allow to specify truncation bits on auth algo
Date: Wed, 02 Feb 2011 17:34:35 +0100
Message-ID: <4D49879B.4060108@6wind.com>
References: <20110128045108.GA8351@gondor.apana.org.au>	<4D42839C.3050401@6wind.com> <20110128.114610.193716130.davem@davemloft.net> <4D498693.6020909@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050902000403040903010303"
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, christophe.gouault@6wind.com
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42377 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345Ab1BBQej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 11:34:39 -0500
Received: by fxm20 with SMTP id 20so152919fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Feb 2011 08:34:38 -0800 (PST)
In-Reply-To: <4D498693.6020909@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050902000403040903010303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 02/02/2011 17:30, Nicolas Dichtel wrote:
> On 28/01/2011 20:46, David Miller wrote:
>> From: Nicolas Dichtel<nicolas.dichtel@6wind.com>
>> Date: Fri, 28 Jan 2011 09:51:40 +0100
>>
>>> On 28/01/2011 05:51, Herbert Xu wrote:
>>>> So perhaps an SA configuration flag is needed?
>>> I agree. If David is ok, I will update the patch.
>>
>> Sounds good to me.
> And the patch for iproute2.
Sorry, two patches were mixed :(

Here is the right one.


Regards,
Nicolas

--------------050902000403040903010303
Content-Type: text/x-patch;
 name="0001-iproute2-add-support-of-flag-XFRM_STATE_ALIGN4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-iproute2-add-support-of-flag-XFRM_STATE_ALIGN4.patch"

>From fe61b9c3564b2f9504bca652cdea80ff3b5a2743 Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 1 Feb 2011 07:29:54 -0500
Subject: [PATCH] iproute2: add support of flag XFRM_STATE_ALIGN4

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/xfrm.h |    1 +
 ip/ipxfrm.c          |    1 +
 ip/xfrm_state.c      |    4 +++-
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 07f2b63..8b2d220 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -349,6 +349,7 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_WILDRECV	8
 #define XFRM_STATE_ICMP		16
 #define XFRM_STATE_AF_UNSPEC	32
+#define XFRM_STATE_ALIGN4	64
 };
 
 struct xfrm_usersa_id {
diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 9753822..ba7360f 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -828,6 +828,7 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_WILDRECV, "wildrecv");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_ICMP, "icmp");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_AF_UNSPEC, "af-unspec");
+		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_ALIGN4, "align4");
 		if (flags)
 			fprintf(fp, "%x", flags);
 	}
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 38d4039..e8c7c96 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -83,7 +83,7 @@ static void usage(void)
  	//fprintf(stderr, "REQID - number(default=0)\n");
 
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
-	fprintf(stderr, "FLAG := [ noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec ]\n");
+	fprintf(stderr, "FLAG := [ noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec | align4 ]\n");
 
         fprintf(stderr, "ENCAP := ENCAP-TYPE SPORT DPORT OADDR\n");
         fprintf(stderr, "ENCAP-TYPE := espinudp | espinudp-nonike\n");
@@ -214,6 +214,8 @@ static int xfrm_state_flag_parse(__u8 *flags, int *argcp, char ***argvp)
 				*flags |= XFRM_STATE_ICMP;
 			else if (strcmp(*argv, "af-unspec") == 0)
 				*flags |= XFRM_STATE_AF_UNSPEC;
+			else if (strcmp(*argv, "align4") == 0)
+				*flags |= XFRM_STATE_ALIGN4;
 			else {
 				PREV_ARG(); /* back track */
 				break;
-- 
1.5.6.5


--------------050902000403040903010303--
