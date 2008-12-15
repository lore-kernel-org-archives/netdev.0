From: Patrick McHardy <kaber@trash.net>
Subject: netfilter: ctnetlink: fix missing CTA_NAT_SEQ_UNSPEC
Date: Mon, 15 Dec 2008 16:42:04 +0100
Message-ID: <49467ACC.8080107@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090302020200080507080306"
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090302020200080507080306
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,

following is a single netfilter patch for 2.6.28, fixing incorrect
ctnetlink NAT attribute definitions that break common userspace
attribute parsing code.

Please apply, thanks.


--------------090302020200080507080306
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 492092c2b1fc3d74b24d8744ba419dbcefadaf5e
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Thu Dec 11 14:00:21 2008 +0100

    netfilter: ctnetlink: fix missing CTA_NAT_SEQ_UNSPEC
    
    This patch fixes an inconsistency in nfnetlink_conntrack.h that
    I introduced myself. The problem is that CTA_NAT_SEQ_UNSPEC is
    missing from enum ctattr_natseq. This inconsistency may lead to
    problems in the message parsing in userspace (if the message
    contains the CTA_NAT_SEQ_* attributes, of course).
    
    This patch breaks backward compatibility, however, the only known
    client of this code is libnetfilter_conntrack which indeed crashes
    because it assumes the existence of CTA_NAT_SEQ_UNSPEC to do
    the parsing.
    
    The CTA_NAT_SEQ_* attributes were introduced in 2.6.25.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index c19595c..29fe9ea 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -141,6 +141,7 @@ enum ctattr_protonat {
 #define CTA_PROTONAT_MAX (__CTA_PROTONAT_MAX - 1)
 
 enum ctattr_natseq {
+	CTA_NAT_SEQ_UNSPEC,
 	CTA_NAT_SEQ_CORRECTION_POS,
 	CTA_NAT_SEQ_OFFSET_BEFORE,
 	CTA_NAT_SEQ_OFFSET_AFTER,

--------------090302020200080507080306--
