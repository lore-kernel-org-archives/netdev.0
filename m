From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: [PATCH v2] net: inet: diag: expose sockets cgroup classid
Date: Thu, 27 Jul 2017 18:11:32 +0000
Message-ID: <20170727181352.18547-1-alexander.levin@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is useful for directly looking up a task based on class id rather than
having to scan through all open file descriptors.

Signed-off-by: Sasha Levin <alexander.levin@verizon.com>
---

Changes in V2:
 - Addressed comments from Cong Wang (use nla_put_u32())

 include/uapi/linux/inet_diag.h |  1 +
 net/ipv4/inet_diag.c           | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.=
h
index bbe201047df6..678496897a68 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -142,6 +142,7 @@ enum {
 	INET_DIAG_PAD,
 	INET_DIAG_MARK,
 	INET_DIAG_BBRINFO,
+	INET_DIAG_CLASS_ID,
 	__INET_DIAG_MAX,
 };
=20
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 3828b3a805cd..2c2445d4bb58 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -274,6 +274,16 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_con=
nection_sock *icsk,
 			goto errout;
 	}
=20
+	if (ext & (1 << (INET_DIAG_CLASS_ID - 1))) {
+		u32 classid =3D 0;
+
+#ifdef CONFIG_SOCK_CGROUP_DATA
+		classid =3D sock_cgroup_classid(&sk->sk_cgrp_data);
+#endif
+
+		nla_put_u32(skb, INET_DIAG_CLASS_ID, classid);
+	}
+
 out:
 	nlmsg_end(skb, nlh);
 	return 0;
--=20
2.11.0
