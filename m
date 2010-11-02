From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [SECURITY] memory corruption in X.25 facilities parsing
Date: Tue, 02 Nov 2010 11:02:48 -0400
Message-ID: <1288710168.2504.6.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:49506 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966Ab0KBPCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 11:02:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I put this together after a quick glance, so if someone knows this code
better than I do (i.e. at all), feel free to comment or drop this patch
if it's unnecessary.

A value of 0 will cause a memcpy() of ULONG_MAX size, destroying the
kernel heap.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

--- linux-2.6.36-rc6.orig/net/x25/x25_facilities.c	2010-09-28 21:01:22.000000000 -0400
+++ linux-2.6.36-rc6/net/x25/x25_facilities.c	2010-11-02 10:36:02.827291324 -0400
@@ -134,14 +134,14 @@ int x25_parse_facilities(struct sk_buff 
 		case X25_FAC_CLASS_D:
 			switch (*p) {
 			case X25_FAC_CALLING_AE:
-				if (p[1] > X25_MAX_DTE_FACIL_LEN)
+				if (p[1] > X25_MAX_DTE_FACIL_LEN || p[1] == 0)
 					break;
 				dte_facs->calling_len = p[2];
 				memcpy(dte_facs->calling_ae, &p[3], p[1] - 1);
 				*vc_fac_mask |= X25_MASK_CALLING_AE;
 				break;
 			case X25_FAC_CALLED_AE:
-				if (p[1] > X25_MAX_DTE_FACIL_LEN)
+				if (p[1] > X25_MAX_DTE_FACIL_LEN || p[1] == 0)
 					break;
 				dte_facs->called_len = p[2];
 				memcpy(dte_facs->called_ae, &p[3], p[1] - 1);


