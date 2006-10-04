From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 1/1] secid reconcialiation: Replace unlabeled_t with the network_t
Date: Tue, 03 Oct 2006 21:41:51 -0500
Message-ID: <45231F6F.4030509@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	paul.moore@hp.com, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:10881 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1030709AbWJDCmy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 22:42:54 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following replaces unlabeled_t with network_t for
better characterization of the flow out/in checks in
SELinux, as well as to allow for mls packets to
flow out/in from the network since network_t would allow
the full range of MLS labels, as opposed to the unlabeled init sid
that only allows system-hi.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
This is an incremental patch the secid-reconcilation v4 patchset.

--- net-2.6.sid3/security/selinux/hooks.c	2006-10-01 15:43:12.000000000 -0500
+++ net-2.6/security/selinux/hooks.c	2006-10-03 16:43:21.000000000 -0500
@@ -3703,7 +3703,8 @@ static int selinux_skb_flow_in(struct sk
 	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
 	BUG_ON(err);
 
-	err = avc_has_perm(xfrm_sid, skb->secmark, SECCLASS_PACKET,
+	err = avc_has_perm(xfrm_sid, skb->secmark? : SECINITSID_NETMSG,
+					SECCLASS_PACKET,
 					PACKET__FLOW_IN, NULL);
 	if (err)
 		goto out;
@@ -3900,7 +3901,7 @@ static unsigned int selinux_ip_postroute
 				skb->secmark = sksec->sid;
 			}
 		}
-		err = avc_has_perm(skb->secmark, SECINITSID_UNLABELED,
+		err = avc_has_perm(skb->secmark, SECINITSID_NETMSG,
 				   SECCLASS_PACKET, PACKET__FLOW_OUT, &ad);
 	}
 out:
