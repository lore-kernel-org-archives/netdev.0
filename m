From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 17/43] netfilter: use forward declaration instead of including linux/proc_fs.h
Date: Wed, 17 Jun 2015 10:28:26 -0500
Message-ID: <1434554932-4552-17-git-send-email-ebiederm@xmission.com>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:39918 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757470AbbFQPi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:29 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pablo Neira Ayuso <pablo@netfilter.org>

We don't need to pull the full definitions in that file, a simple forwa=
rd
declaration is enough.

Moreover, include linux/procfs.h from nf_synproxy_core, otherwise this =
hits a
compilation error due to missing declarations, ie.

net/netfilter/nf_synproxy_core.c: In function =E2=80=98synproxy_proc_in=
it=E2=80=99:
net/netfilter/nf_synproxy_core.c:326:2: error: implicit declaration of =
function =E2=80=98proc_create=E2=80=99 [-Werror=3Dimplicit-function-dec=
laration]
  if (!proc_create("synproxy", S_IRUGO, net->proc_net_stat,
  ^

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/netns/netfilter.h    | 2 +-
 net/netfilter/nf_synproxy_core.c | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/netns/netfilter.h b/include/net/netns/netfilte=
r.h
index 88740024ccf3..cf25b5e35f3c 100644
--- a/include/net/netns/netfilter.h
+++ b/include/net/netns/netfilter.h
@@ -1,9 +1,9 @@
 #ifndef __NETNS_NETFILTER_H
 #define __NETNS_NETFILTER_H
=20
-#include <linux/proc_fs.h>
 #include <linux/netfilter.h>
=20
+struct proc_dir_entry;
 struct nf_logger;
=20
 struct netns_nf {
diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synpro=
xy_core.c
index 52e20c9a46a5..789feeae6c44 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -11,6 +11,7 @@
 #include <asm/unaligned.h>
 #include <net/tcp.h>
 #include <net/netns/generic.h>
+#include <linux/proc_fs.h>
=20
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <linux/netfilter/x_tables.h>
--=20
2.2.1
