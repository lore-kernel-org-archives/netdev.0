From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: [PATCH next] net: netfilter: nfnetlink_cthelper: Remove 'const' and
 '&' to avoid warnings
Date: Wed, 24 Dec 2014 23:04:54 +0800
Message-ID: <549AD616.7070709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The related code can be simplified, and also can avoid related warnings
(with allmodconfig under parisc):

    CC [M]  net/netfilter/nfnetlink_cthelper.o
  net/netfilter/nfnetlink_cthelper.c: In function =E2=80=98nfnl_cthelpe=
r_from_nlattr=E2=80=99:
  net/netfilter/nfnetlink_cthelper.c:97:9: warning: passing argument 1 =
o =E2=80=98memcpy=E2=80=99 discards =E2=80=98const=E2=80=99 qualifier f=
rom pointer target type [-Wdiscarded-array-qualifiers]
    memcpy(&help->data, nla_data(attr), help->helper->data_len);
           ^
  In file included from include/linux/string.h:17:0,
                   from include/uapi/linux/uuid.h:25,
                   from include/linux/uuid.h:23,
                   from include/linux/mod_devicetable.h:12,
                   from ./arch/parisc/include/asm/hardware.h:4,
                   from ./arch/parisc/include/asm/processor.h:15,
                   from ./arch/parisc/include/asm/spinlock.h:6,
                   from ./arch/parisc/include/asm/atomic.h:21,
                   from include/linux/atomic.h:4,
                   from ./arch/parisc/include/asm/bitops.h:12,
                   from include/linux/bitops.h:36,
                   from include/linux/kernel.h:10,
                   from include/linux/list.h:8,
                   from include/linux/module.h:9,
                   from net/netfilter/nfnetlink_cthelper.c:11:
  ./arch/parisc/include/asm/string.h:8:8: note: expected =E2=80=98void =
*=E2=80=99 but argument is of type =E2=80=98const char (*)[]=E2=80=99
   void * memcpy(void * dest,const void *src,size_t count);
          ^

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 net/netfilter/nfnetlink_cthelper.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetli=
nk_cthelper.c
index 9e287cb..a5599fc 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -86,7 +86,7 @@ nfnl_cthelper_parse_tuple(struct nf_conntrack_tuple *=
tuple,
 static int
 nfnl_cthelper_from_nlattr(struct nlattr *attr, struct nf_conn *ct)
 {
-	const struct nf_conn_help *help =3D nfct_help(ct);
+	struct nf_conn_help *help =3D nfct_help(ct);
=20
 	if (attr =3D=3D NULL)
 		return -EINVAL;
@@ -94,7 +94,7 @@ nfnl_cthelper_from_nlattr(struct nlattr *attr, struct=
 nf_conn *ct)
 	if (help->helper->data_len =3D=3D 0)
 		return -EINVAL;
=20
-	memcpy(&help->data, nla_data(attr), help->helper->data_len);
+	memcpy(help->data, nla_data(attr), help->helper->data_len);
 	return 0;
 }
=20
--=20
1.7.9.5
