From: Cong Wang <amwang@redhat.com>
Subject: =?UTF-8?q?=5BPatch=20net-next=5D=20sctp=3A=20fix=20a=20compile=20error=20in=20sctp=2Eh?=
Date: Wed, 15 Aug 2012 18:18:11 +0800
Message-ID: <1345025891-5021-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751549Ab2HOKSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2012 06:18:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got the following compile error:

In file included from include/net/sctp/checksum.h:46:0,
                 from net/ipv4/netfilter/nf_nat_proto_sctp.c:14:
include/net/sctp/sctp.h: In function =E2=80=98sctp_dbg_objcnt_init=E2=80=
=99:
include/net/sctp/sctp.h:370:88: error: parameter name omitted
include/net/sctp/sctp.h: In function =E2=80=98sctp_dbg_objcnt_exit=E2=80=
=99:
include/net/sctp/sctp.h:371:88: error: parameter name omitted

which is caused by

	commit 13d782f6b4fbbaf9d0380a9947deb45a9de46ae7
	Author: Eric W. Biederman <ebiederm@xmission.com>
	Date:   Mon Aug 6 08:45:15 2012 +0000

	    sctp: Make the proc files per network namespace.

This patch could fix it.

Cc: David S. Miller <davem@davemloft.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index aaa8292..9c6414f 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -367,8 +367,8 @@ void sctp_dbg_objcnt_exit(struct net *);
 #define SCTP_DBG_OBJCNT_INC(name)
 #define SCTP_DBG_OBJCNT_DEC(name)
=20
-static inline void sctp_dbg_objcnt_init(struct net *) { return; }
-static inline void sctp_dbg_objcnt_exit(struct net *) { return; }
+static inline void sctp_dbg_objcnt_init(struct net *net) { return; }
+static inline void sctp_dbg_objcnt_exit(struct net *net) { return; }
=20
 #endif /* CONFIG_SCTP_DBG_OBJCOUNT */
=20
