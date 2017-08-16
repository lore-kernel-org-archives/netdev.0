From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: Re: [PATCH v2] net: inet: diag: expose sockets cgroup classid
Date: Wed, 16 Aug 2017 20:13:02 +0000
Message-ID: <20170816201707.xbpquud3ar3uarst@sasha-lappy>
References: <20170727181352.18547-1-alexander.levin@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170727181352.18547-1-alexander.levin@verizon.com>
Content-Language: en-US
Content-ID: <B18728671C05F341940C96AFC9854250@vzwcorp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ping?

On Thu, Jul 27, 2017 at 02:13:52PM -0400, Sasha Levin wrote:
>This is useful for directly looking up a task based on class id rather tha=
n
>having to scan through all open file descriptors.
>
>Signed-off-by: Sasha Levin <alexander.levin@verizon.com>
>---
>
>Changes in V2:
> - Addressed comments from Cong Wang (use nla_put_u32())
>
> include/uapi/linux/inet_diag.h |  1 +
> net/ipv4/inet_diag.c           | 10 ++++++++++
> 2 files changed, 11 insertions(+)
>
>diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag=
.h
>index bbe201047df6..678496897a68 100644
>--- a/include/uapi/linux/inet_diag.h
>+++ b/include/uapi/linux/inet_diag.h
>@@ -142,6 +142,7 @@ enum {
> 	INET_DIAG_PAD,
> 	INET_DIAG_MARK,
> 	INET_DIAG_BBRINFO,
>+	INET_DIAG_CLASS_ID,
> 	__INET_DIAG_MAX,
> };
>
>diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
>index 3828b3a805cd..2c2445d4bb58 100644
>--- a/net/ipv4/inet_diag.c
>+++ b/net/ipv4/inet_diag.c
>@@ -274,6 +274,16 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_co=
nnection_sock *icsk,
> 			goto errout;
> 	}
>
>+	if (ext & (1 << (INET_DIAG_CLASS_ID - 1))) {
>+		u32 classid =3D 0;
>+
>+#ifdef CONFIG_SOCK_CGROUP_DATA
>+		classid =3D sock_cgroup_classid(&sk->sk_cgrp_data);
>+#endif
>+
>+		nla_put_u32(skb, INET_DIAG_CLASS_ID, classid);
>+	}
>+
> out:
> 	nlmsg_end(skb, nlh);
> 	return 0;
>--=20
>2.11.0

--=20

Thanks,
Sasha=
