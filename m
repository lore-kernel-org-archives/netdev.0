From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: Tree for April 7 (net/core/dev_addr_lists)
Date: Wed, 07 Apr 2010 19:38:09 +0200
Message-ID: <1270661889.8141.45.camel@edumazet-laptop>
References: <20100407174123.81b32310.sfr@canb.auug.org.au>
	 <20100407095845.f29ebf48.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100407095845.f29ebf48.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 07 avril 2010 =C3=A0 09:58 -0700, Randy Dunlap a =C3=A9crit=
 :
> On Wed, 7 Apr 2010 17:41:23 +1000 Stephen Rothwell wrote:
>=20
> > Hi all,
> >=20
> > Changes since 20100401:
>=20
>=20
> when CONFIG_PROC_FS is disabled:
>=20
> linux-next-20100407/net/core/dev_addr_lists.c: In function 'dev_mc_ne=
t_init':
> linux-next-20100407/net/core/dev_addr_lists.c:722: error: implicit de=
claration of function 'proc_net_fops_create'
> linux-next-20100407/net/core/dev_addr_lists.c:722: error: 'dev_mc_seq=
_fops' undeclared (first use in this function)
> linux-next-20100407/net/core/dev_addr_lists.c:722: error: (Each undec=
lared identifier is reported only once
> linux-next-20100407/net/core/dev_addr_lists.c:722: error: for each fu=
nction it appears in.)
> linux-next-20100407/net/core/dev_addr_lists.c: In function 'dev_mc_ne=
t_exit':
> linux-next-20100407/net/core/dev_addr_lists.c:729: error: implicit de=
claration of function 'proc_net_remove'
> make[3]: *** [net/core/dev_addr_lists.o] Error 1
>=20
> ---
> ~Randy

Thanks Randy, this should correct this

[PATCH net-next-2.6] net: include linux/proc_fs.h in dev_addr_lists.c

As pointed by Randy Dunlap, we must include linux/proc_fs.h in
net/core/dev_addr_lists.c, regardless of CONFIG_PROC_FS

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>,=20
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 37d5975..508f9c1 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -14,6 +14,7 @@
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/list.h>
+#include <linux/proc_fs.h>
=20
 /*
  * General list handling functions
@@ -667,7 +668,6 @@ void dev_mc_init(struct net_device *dev)
 EXPORT_SYMBOL(dev_mc_init);
=20
 #ifdef CONFIG_PROC_FS
-#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
=20
 static int dev_mc_seq_show(struct seq_file *seq, void *v)
