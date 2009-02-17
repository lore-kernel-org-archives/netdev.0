From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/1 net-next] Fix infiniband warnings
Date: Tue, 17 Feb 2009 11:13:59 -0300
Message-ID: <499AC627.2090908@linux.vnet.ibm.com>
References: <1231651594.5714.65.camel@brick> <499AC4E9.7090307@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>,
	Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:55872 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbZBQOOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 09:14:08 -0500
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp02.br.ibm.com (8.13.1/8.13.1) with ESMTP id n1HENJog007185
	for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 11:23:19 -0300
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1HFDSIp3645444
	for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 12:13:30 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1HEE1Ai020054
	for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 11:14:01 -0300
In-Reply-To: <499AC4E9.7090307@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 03080e5cbe0222744173d3e726f6ba5d13b7f04e is causing some warning
during compilation.

tmp_addr is an unused variable if CONFIG_INFINIBAND_NES_DEBUG is
 not used. Causing the following Warning.

drivers/infiniband/hw/nes/nes_cm.c: In function =E2=80=98find_node=E2=80=
=99:
drivers/infiniband/hw/nes/nes_cm.c:781: warning: unused variable =E2=80=
=98tmp_addr=E2=80=99
drivers/infiniband/hw/nes/nes_cm.c: In function =E2=80=98find_listener=E2=
=80=99:
drivers/infiniband/hw/nes/nes_cm.c:820: warning: unused variable =E2=80=
=98tmp_addr=E2=80=99

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

---
 drivers/infiniband/hw/nes/nes_cm.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw=
/nes/nes_cm.c
index a01b448..2b34859 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -778,7 +778,9 @@ static struct nes_cm_node *find_node(struct nes_cm_=
core *cm_core,
 	unsigned long flags;
 	struct list_head *hte;
 	struct nes_cm_node *cm_node;
+#ifdef CONFIG_INFINIBAND_NES_DEBUG
 	__be32 tmp_addr =3D cpu_to_be32(loc_addr);
+#endif

 	/* get a handle on the hte */
 	hte =3D &cm_core->connected_nodes;
@@ -817,7 +819,9 @@ static struct nes_cm_listener *find_listener(struct=
 nes_cm_core *cm_core,
 {
 	unsigned long flags;
 	struct nes_cm_listener *listen_node;
+#ifdef CONFIG_INFINIBAND_NES_DEBUG
 	__be32 tmp_addr =3D cpu_to_be32(dst_addr);
+#endif

 	/* walk list and find cm_node associated with this session ID */
 	spin_lock_irqsave(&cm_core->listen_list_lock, flags);
