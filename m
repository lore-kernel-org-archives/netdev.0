From: Jaroslav =?utf-8?B?xaBhZmth?= <jaroslav.safka@tieto.com>
Subject: iproute2 small patches for xfrm
Date: Fri, 01 Aug 2014 13:16:09 +0200
Message-ID: <2141002.LfKmUBSlWz@ul001176>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nextPart14368611.dDquY92tuI"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:38296 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbaHALQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 07:16:09 -0400
Received: by mail-la0-f44.google.com with SMTP id e16so3112709lan.31
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 04:16:07 -0700 (PDT)
Received: from ul001176.eu.tieto.com ([131.207.242.140])
        by mx.google.com with ESMTPSA id xx9sm12766536lbb.30.2014.08.01.04.16.04
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Aug 2014 04:16:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--nextPart14368611.dDquY92tuI
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"

Hi,
I found the tool "ip xfrm" is not able to add "cipher_null" because there is 
no possibility to set key with zero length.

I solved it by this change:

-       if (slen > 2 && strncmp(key, "0x", 2) == 0) {
+       if (slen >= 2 && strncmp(key, "0x", 2) == 0) {

By this change you can specify key as "0x" which will pass for key existence 
and set key len to 0.

this patch is against version iproute2-3.14.0

Second patch enable use proto ip. Because it is supported by kernel.

Have a nice day :)

Regards
Jarek

--nextPart14368611.dDquY92tuI
Content-Disposition: attachment; filename="cipher_null.patch"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-patch; charset="utf-8"; name="cipher_null.patch"

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 140a450..d7d13c8 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -125,7 +125,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 
 	strncpy(alg->alg_name, name, sizeof(alg->alg_name));
 
-	if (slen > 2 && strncmp(key, "0x", 2) == 0) {
+	if (slen >= 2 && strncmp(key, "0x", 2) == 0) {
 		/* split two chars "0x" from the top */
 		char *p = key + 2;
 		int plen = slen - 2;

--nextPart14368611.dDquY92tuI
Content-Disposition: attachment; filename="proto_ip.patch"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-patch; charset="utf-8"; name="proto_ip.patch"

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index cce5151..05e4098 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -1280,6 +1281,7 @@ static int xfrm_selector_upspec_parse(struct xfrm_selector *sel,
 		missarg("UPSPEC");
 	if (sportp || dportp) {
 		switch (sel->proto) {
+		case IPPROTO_IP:
 		case IPPROTO_TCP:
 		case IPPROTO_UDP:
 		case IPPROTO_SCTP:

--nextPart14368611.dDquY92tuI--
