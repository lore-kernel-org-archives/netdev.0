From: Ingo Molnar <mingo@elte.hu>
Subject: [warnings] 37 warning fixes in networking related files
Date: Wed, 26 Nov 2008 02:09:27 +0100
Message-ID: <20081126010927.GA9527@elte.hu>
References: <20081125085820.GA11401@elte.hu> <20081125152014.GB29096@gondor.apana.org.au> <20081125171438.GK22504@elte.hu> <20081125.135231.81163255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081125.135231.81163255.davem@davemloft.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Tue, 25 Nov 2008 18:14:38 +0100
>=20
> > btw, on a related note, there's a couple of networking related warn=
ing=20
> > fixes/annotations i've got queued up.
>=20
> I see these now, but they would get properly logged and
> tracked at:
>=20
> 	http://patchwork.ozlabs.org/project/netdev/
>=20
> if you would simply CC: netdev instead of sending them into
> the ether by informing lkml and the crypto list about them.

sure - netdev Cc:-ed, subject line changed - mail repeated below.

This one seems to be a real bug too (subject line nonwithstanding):

  69f38f6: fix warning in drivers/net/depca.c

besides the bugfixes, the annotations would be nice to have too - i=20
got the warnings with latest-gcc (4.3.2) and once we reach a baseline=20
of no warnings it will be much easier to go forward in a delta manner.=20
At that points commits that actually cause new warnings will be much=20
fresher - and the warnings will be a lot more interesting in general=20
as well.

Right now we've got a baseline noise where it's mostly GCC that is=20
wrong. Obviously those are the warnings that tend to linger around in=20
the kernel source: people see the warnings and determine that GCC is=20
wrong and keep the source unchanged.

The arch/x86/* files already have a zero warnings baseline (clean=20
-Werror builds), and my experience is that the new warnings that pop=20
up are generally quite healthy and interesting, with a low false=20
positive rate.

Hm?

	Ingo

---------------->

I've got 37 commits of that nature in the tip/warnings/* topic=20
branches:

  d94b43b: fix warning in drivers/net/s2io.c
  78f065d: fix warnings in drivers/net/niu.c
  9cc0c65: fix warning in drivers/net/niu.c
  32fd3b5: fix warning in drivers/net/qla3xxx.c
  ba58621: fix warning in net/sunrpc/xprtrdma/svc_rdma_transport.c
  b91eb99: fix warning in net/sched/sch_hfsc.c
  c390a37: fix warning in net/netfilter/nf_conntrack_ftp.c
  8fecea6: fix warning in net/ipv6/ip6_flowlabel.c
  e5e5492: fix warning in drivers/net/wan/z85230.c
  67230f2: fix warning in net/dsa/mv88e6xxx.c
  948158e: fix warning in net/dsa/mv88e6060.c
  8574b3b: fix warning in fs/dlm/netlink.c
  9b9c8fd: fix warning in drivers/net/sis900.c
  924a289: fix warning in drivers/net/wireless/iwlwifi/iwl-3945.c
  2267239: fix warning in drivers/net/wireless/b43/main.c
  de96506: fix warning in drivers/net/wireless/ath9k/rc.c
  742cddc: fix error path in drivers/net/mlx4/en_rx.c
  181787d: fix warning in drivers/net/cassini.c
  96c7925: fix warning in net/dccp/options.c
  193e56a: fix warning in drivers/net/mlx4/mcg.c
  bcc35f7: fix warning in net/ax25/sysctl_net_ax25.c
  59681c6: fix warning in net/sunrpc/xprtrdma/verbs.c
  ad8d03b: fix warning in net/bluetooth/rfcomm/sock.c
  320451a: fix warning in drivers/net/wireless/ray_cs.c
  decc165: fix warning in net/netfilter/nf_conntrack_proto_sctp.c
  b547d51: fix warning in net/netfilter/ipvs/ip_vs_ctl.c
  2281d27: fix warning in drivers/net/atlx/atl2.c
  b5a7c2b: fix warning in net/netfilter/nf_conntrack_proto_tcp.c
  822c18d: fix warning in drivers/net/wireless/iwlwifi/iwl-scan.c
  69f38f6: fix warning in drivers/net/depca.c
  557073e: fix warning in drivers/net/3c523.c
  d138e44: drivers/net/wireless/b43/phy_g.c: type check debug printouts
  7e4f788: fix warning in drivers/net/sky2.c
  deb797f: fix warning in net/sunrpc/svcauth_unix.c
  923a5a9: fix warning in security/selinux/netnode.c
  c62cda5: fix warning in net/packet/af_packet.c
  d581867: fix warning in net/rfkill/rfkill.c

Note that the reason there's so many annotations is that this a full=20
range of fixes for allyes/allno/allmod and randconfig kernels on x86.=20
That's a lot of build configurations and a lot of warnings to=20
annotate.

Another one of them is a real bugfix:

  742cddc: fix error path in drivers/net/mlx4/en_rx.c

these are side products of -tip's -Werror testing, i.e. not merged=20
anywhere in the direction of linux-next or -git (obviously).

They are done mainly so that we can notice the warnings we introduce=20
via any of the -tip trees - but we analyze and look at all other types=20
of upstream kernel warnings as well.

I'll thus keep these commits indefinitely - but if someone from the=20
networking side would like to work with us to pick them up and=20
eventually nurse them upstream, that would be great!

One thing is not really feasible: there's just too many of them for me=20
to spend 10 minutes on each to submit them with a proper Cc:, etc.=20
(such overhead mounts up quickly if you do the numbers)

So i've attached them below as a dump of patches. If someone wants to=20
cherry-pick bits of them, they are also available in=20
tip/auto-warnings-next:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git =
auto-warnings-next

Warning: some of them might be bad, so please double check the=20
analysis.

	Ingo

-------------->
commit d94b43b196712688c7b018edd69a4ca1650f61e0
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 12:55:10 2008 +0100

    fix warning in drivers/net/s2io.c
   =20
    this warning:
   =20
      drivers/net/s2io.c: In function =E2=80=98rx_intr_handler=E2=80=99=
:
      drivers/net/s2io.c:7369: warning: =E2=80=98lro=E2=80=99 may be us=
ed uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between:
   =20
     - s2io_club_tcp_session()and 'lro'
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 6a1375f..a150575 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7366,7 +7366,7 @@ static int rx_osm_handler(struct ring_info *ring_=
data, struct RxD_t * rxdp)
 	int ring_no =3D ring_data->ring_no;
 	u16 l3_csum, l4_csum;
 	unsigned long long err =3D rxdp->Control_1 & RXD_T_CODE;
-	struct lro *lro;
+	struct lro *uninitialized_var(lro);
 	u8 err_mask;
=20
 	skb->dev =3D dev;

commit 78f065dd3b7f8116dafc7eb6bf966e8276580c15
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 12:58:10 2008 +0100

    fix warnings in drivers/net/niu.c
   =20
    these warnings:
   =20
      drivers/net/niu.c: In function =E2=80=98serdes_init_niu_1g_serdes=
=E2=80=99:
      drivers/net/niu.c:451: warning: =E2=80=98sig=E2=80=99 may be used=
 uninitialized in this function
      drivers/net/niu.c: In function =E2=80=98serdes_init_niu_10g_serde=
s=E2=80=99:
      drivers/net/niu.c:550: warning: =E2=80=98sig=E2=80=99 may be used=
 uninitialized in this function
   =20
    triggers because GCC does not recognize that the max_retry loop
    always initializes 'sig', due to max_retry !=3D 0.
   =20
    Annotate them.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index afa399c..7e25142 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -448,7 +448,7 @@ static int serdes_init_niu_1g_serdes(struct niu *np=
)
 	struct niu_link_config *lp =3D &np->link_config;
 	u16 pll_cfg, pll_sts;
 	int max_retry =3D 100;
-	u64 sig, mask, val;
+	u64 uninitialized_var(sig), mask, val;
 	u32 tx_cfg, rx_cfg;
 	unsigned long i;
 	int err;
@@ -547,7 +547,7 @@ static int serdes_init_niu_10g_serdes(struct niu *n=
p)
 	struct niu_link_config *lp =3D &np->link_config;
 	u32 tx_cfg, rx_cfg, pll_cfg, pll_sts;
 	int max_retry =3D 100;
-	u64 sig, mask, val;
+	u64 uninitialized_var(sig), mask, val;
 	unsigned long i;
 	int err;
=20

commit 9cc0c65af74e02da2c3d621cb061bd61b64cc24e
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 12:54:50 2008 +0100

    fix warning in drivers/net/niu.c
   =20
    this warning:
   =20
      drivers/net/niu.c: In function =E2=80=98esr_reset=E2=80=99:
      drivers/net/niu.c:741: warning: =E2=80=98reset=E2=80=99 may be us=
ed uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between:
   =20
     - esr_read_reset() and 'reset'
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 1b6f548..afa399c 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -738,7 +738,7 @@ static int esr_write_glue0(struct niu *np, unsigned=
 long chan, u32 val)
=20
 static int esr_reset(struct niu *np)
 {
-	u32 reset;
+	u32 uninitialized_var(reset);
 	int err;
=20
 	err =3D mdio_write(np, np->port, NIU_ESR_DEV_ADDR,

commit 32fd3b535aa43e290c33873124f91fec6a4329f7
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 12:37:40 2008 +0100

    fix warning in drivers/net/qla3xxx.c
   =20
    this warning:
   =20
      drivers/net/qla3xxx.c: In function =E2=80=98ql3xxx_probe=E2=80=99=
:
      drivers/net/qla3xxx.c:3912: warning: =E2=80=98pci_using_dac=E2=80=
=99 may be used uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between 'pci_using_dac' and 'err'.
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 508452c..3ae623e 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3909,7 +3909,7 @@ static int __devinit ql3xxx_probe(struct pci_dev =
*pdev,
 	struct net_device *ndev =3D NULL;
 	struct ql3_adapter *qdev =3D NULL;
 	static int cards_found =3D 0;
-	int pci_using_dac, err;
+	int uninitialized_var(pci_using_dac), err;
=20
 	err =3D pci_enable_device(pdev);
 	if (err) {

commit ba58621694ef08b59b753bc5042b3db9472c5aff
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 12:03:21 2008 +0100

    fix warning in net/sunrpc/xprtrdma/svc_rdma_transport.c
   =20
    this warning:
   =20
      net/sunrpc/xprtrdma/svc_rdma_transport.c: In function =E2=80=98sv=
c_rdma_accept=E2=80=99:
      net/sunrpc/xprtrdma/svc_rdma_transport.c:830: warning: =E2=80=98d=
ma_mr_acc=E2=80=99 may be used uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) flow connecti=
on
    between need_dma_mr and dma_mr_acc.
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprt=
rdma/svc_rdma_transport.c
index 6fb493c..636095c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -827,7 +827,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_=
xprt *xprt)
 	struct rdma_conn_param conn_param;
 	struct ib_qp_init_attr qp_attr;
 	struct ib_device_attr devattr;
-	int dma_mr_acc;
+	int uninitialized_var(dma_mr_acc);
 	int need_dma_mr;
 	int ret;
 	int i;

commit b91eb990a0d839e810bb15048af08a69ab1b6ffe
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 12:03:12 2008 +0100

    fix warning in net/sched/sch_hfsc.c
   =20
    this warning:
   =20
      net/sched/sch_hfsc.c: In function =E2=80=98hfsc_enqueue=E2=80=99:
      net/sched/sch_hfsc.c:1577: warning: =E2=80=98err=E2=80=99 may be =
used uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between hfsc_classify(), 'cl' and 'err'.
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index c1e77da..b39e3b5 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1574,7 +1574,7 @@ static int
 hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct hfsc_class *cl;
-	int err;
+	int uninitialized_var(err);
=20
 	cl =3D hfsc_classify(skb, sch, &err);
 	if (cl =3D=3D NULL) {

commit c390a3784564c1fb2183e4a31ea39a9beb47d034
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 11:31:28 2008 +0100

    fix warning in net/netfilter/nf_conntrack_ftp.c
   =20
    this warning:
   =20
      net/netfilter/nf_conntrack_ftp.c: In function =E2=80=98help=E2=80=
=99:
      net/netfilter/nf_conntrack_ftp.c:360: warning: =E2=80=98matchoff=E2=
=80=99 may be used uninitialized in this function
      net/netfilter/nf_conntrack_ftp.c:360: warning: =E2=80=98matchlen=E2=
=80=99 may be used uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between find_pattern(), 'found', 'matchoff' and 'matchlen'.
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntr=
ack_ftp.c
index 4f71071..af7ad91 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -357,7 +357,7 @@ static int help(struct sk_buff *skb,
 	int ret;
 	u32 seq;
 	int dir =3D CTINFO2DIR(ctinfo);
-	unsigned int matchlen, matchoff;
+	unsigned int uninitialized_var(matchlen), uninitialized_var(matchoff)=
;
 	struct nf_ct_ftp_master *ct_ftp_info =3D &nfct_help(ct)->help.ct_ftp_=
info;
 	struct nf_conntrack_expect *exp;
 	union nf_inet_addr *daddr;
@@ -592,3 +592,4 @@ static int __init nf_conntrack_ftp_init(void)
=20
 module_init(nf_conntrack_ftp_init);
 module_exit(nf_conntrack_ftp_fini);
+

commit 8fecea67aa434dd1653c4a275532e29903caeb88
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 11:31:20 2008 +0100

    fix warning in net/ipv6/ip6_flowlabel.c
   =20
    this warning:
   =20
      net/ipv6/ip6_flowlabel.c: In function =E2=80=98ipv6_flowlabel_opt=
=E2=80=99:
      net/ipv6/ip6_flowlabel.c:467: warning: =E2=80=98err=E2=80=99 may =
be used uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between fl_create() and 'err'.
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 37a4e77..62809ec 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -464,7 +464,7 @@ static inline void fl_link(struct ipv6_pinfo *np, s=
truct ipv6_fl_socklist *sfl,
=20
 int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optle=
n)
 {
-	int err;
+	int uninitialized_var(err);
 	struct net *net =3D sock_net(sk);
 	struct ipv6_pinfo *np =3D inet6_sk(sk);
 	struct in6_flowlabel_req freq;

commit 67230f214ec140d07fcd32535841ee6eb4437364
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 11:31:12 2008 +0100

    fix warning in net/dsa/mv88e6xxx.c
   =20
    this warning:
   =20
      net/dsa/mv88e6xxx.c: In function =E2=80=98mv88e6xxx_poll_link=E2=80=
=99:
      net/dsa/mv88e6xxx.c:361: warning: =E2=80=98port_status=E2=80=99 m=
ay be used uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between 'link' and 'port_status'.
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/dsa/mv88e6xxx.c b/net/dsa/mv88e6xxx.c
index aa6c609..4e4d8b5 100644
--- a/net/dsa/mv88e6xxx.c
+++ b/net/dsa/mv88e6xxx.c
@@ -358,7 +358,7 @@ void mv88e6xxx_poll_link(struct dsa_switch *ds)
=20
 	for (i =3D 0; i < DSA_MAX_PORTS; i++) {
 		struct net_device *dev;
-		int port_status;
+		int uninitialized_var(port_status);
 		int link;
 		int speed;
 		int duplex;

commit 948158e35984f86e565db303e0f026e536edca85
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 11:31:04 2008 +0100

    fix warning in net/dsa/mv88e6060.c
   =20
    this warning:
   =20
      net/dsa/mv88e6060.c: In function =E2=80=98mv88e6060_poll_link=E2=80=
=99:
      net/dsa/mv88e6060.c:225: warning: =E2=80=98port_status=E2=80=99 m=
ay be used uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between 'link' and 'port_status'.
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/dsa/mv88e6060.c b/net/dsa/mv88e6060.c
index 54068ef..bfb4a64 100644
--- a/net/dsa/mv88e6060.c
+++ b/net/dsa/mv88e6060.c
@@ -222,7 +222,7 @@ static void mv88e6060_poll_link(struct dsa_switch *=
ds)
=20
 	for (i =3D 0; i < DSA_MAX_PORTS; i++) {
 		struct net_device *dev;
-		int port_status;
+		int uninitialized_var(port_status);
 		int link;
 		int speed;
 		int duplex;

commit 8574b3b4834c740d37d6eb2d6839037779b56da4
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 11:30:57 2008 +0100

    fix warning in fs/dlm/netlink.c
   =20
    this warning:
   =20
      fs/dlm/netlink.c: In function =E2=80=98dlm_timeout_warn=E2=80=99:
      fs/dlm/netlink.c:131: warning: =E2=80=98send_skb=E2=80=99 may be =
used uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between prepare_data() and send_skb.
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/fs/dlm/netlink.c b/fs/dlm/netlink.c
index 18bda83..aa2a577 100644
--- a/fs/dlm/netlink.c
+++ b/fs/dlm/netlink.c
@@ -127,8 +127,8 @@ static void fill_data(struct dlm_lock_data *data, s=
truct dlm_lkb *lkb)
=20
 void dlm_timeout_warn(struct dlm_lkb *lkb)
 {
+	struct sk_buff *uninitialized_var(send_skb);
 	struct dlm_lock_data *data;
-	struct sk_buff *send_skb;
 	size_t size;
 	int rv;
=20

commit 9b9c8fde6c9d175bb7a108e3d231626984364451
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 11:30:15 2008 +0100

    fix warning in drivers/net/sis900.c
   =20
    this warning:
   =20
      drivers/net/sis900.c: In function =E2=80=98sis900_timer=E2=80=99:
      drivers/net/sis900.c:1280: warning: =E2=80=98speed=E2=80=99 may b=
e used uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between sis900_read_mode(), 'speed' and 'duplex'.
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index fa3a460..8be433e 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -1277,7 +1277,7 @@ static void sis900_timer(unsigned long data)
 	u16 status;
=20
 	if (!sis_priv->autong_complete){
-		int speed, duplex =3D 0;
+		int uninitialized_var(speed), duplex =3D 0;
=20
 		sis900_read_mode(net_dev, &speed, &duplex);
 		if (duplex){

commit 924a289446dadc9c3c9896c87446e0403c746537
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 10:38:24 2008 +0100

    fix warning in drivers/net/wireless/iwlwifi/iwl-3945.c
   =20
    this warning:
   =20
      drivers/net/wireless/iwlwifi/iwl-3945.c: In function =E2=80=98iwl=
3945_txpower_set_from_eeprom=E2=80=99:
      drivers/net/wireless/iwlwifi/iwl-3945.c:2182: warning: =E2=80=98p=
ower_idx=E2=80=99 may be used uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between iwl3945_hw_reg_get_matched_power_index() and power_idx.
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wire=
less/iwlwifi/iwl-3945.c
index 7ca5627..e9e0b1a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -2179,7 +2179,7 @@ int iwl3945_txpower_set_from_eeprom(struct iwl394=
5_priv *priv)
 		/* set tx power value for all OFDM rates */
 		for (rate_index =3D 0; rate_index < IWL_OFDM_RATES;
 		     rate_index++) {
-			s32 power_idx;
+			s32 uninitialized_var(power_idx);
 			int rc;
=20
 			/* use channel group's clip-power table,

commit 22672393d84dc3c74b7cd46eebdb44d43747318b
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 10:38:08 2008 +0100

    fix warning in drivers/net/wireless/b43/main.c
   =20
    this warning:
   =20
      drivers/net/wireless/b43/main.c: In function =E2=80=98b43_op_conf=
ig=E2=80=99:
      drivers/net/wireless/b43/main.c:3258: warning: =E2=80=98gmode=E2=80=
=99 may be used uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between the list_for_each_entry() loop, up_dev and gmode.
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43=
/main.c
index 14c44df..bd70b27 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -3255,7 +3255,7 @@ static int b43_switch_band(struct b43_wl *wl, str=
uct ieee80211_channel *chan)
 	struct b43_wldev *down_dev;
 	struct b43_wldev *d;
 	int err;
-	bool gmode;
+	bool uninitialized_var(gmode);
 	int prev_status;
=20
 	/* Find a device and PHY which supports the band. */

commit de965062d615afc885bd800976e488bd3c2d1d6f
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 10:37:58 2008 +0100

    fix warning in drivers/net/wireless/ath9k/rc.c
   =20
    this warning:
   =20
      drivers/net/wireless/ath9k/rc.c: In function =E2=80=98ath_rc_rate=
_getidx=E2=80=99:
      drivers/net/wireless/ath9k/rc.c:1033: warning: =E2=80=98nextindex=
=E2=80=99 may be used uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between ath_rc_get_nextlowervalid_txrate() and &nextindex.
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/wireless/ath9k/rc.c b/drivers/net/wireless/ath=
9k/rc.c
index cca2fc5..27b35d3 100644
--- a/drivers/net/wireless/ath9k/rc.c
+++ b/drivers/net/wireless/ath9k/rc.c
@@ -1030,7 +1030,7 @@ static u8 ath_rc_rate_getidx(struct ath_softc *sc=
,
 			     u16 min_rate)
 {
 	u32 j;
-	u8 nextindex;
+	u8 uninitialized_var(nextindex);
 	struct ath_tx_ratectrl *rate_ctrl =3D
 		(struct ath_tx_ratectrl *)(ath_rc_priv);
=20

commit e5e5492e7094ed4bea8daf0302f60fbb21daa4c7
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 14:52:20 2008 +0100

    fix warning in drivers/net/wan/z85230.c
   =20
    this warning:
   =20
      drivers/net/wan/z85230.c: In function =E2=80=98z8530_interrupt=E2=
=80=99:
      drivers/net/wan/z85230.c:713: warning: =E2=80=98intr=E2=80=99 may=
 be used uninitialized in this function
   =20
    is clearly bogus - annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index 5bf7e01..d7bf53a 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -710,7 +710,7 @@ EXPORT_SYMBOL(z8530_nop);
 irqreturn_t z8530_interrupt(int irq, void *dev_id)
 {
 	struct z8530_dev *dev=3Ddev_id;
-	u8 intr;
+	u8 uninitialized_var(intr);
 	static volatile int locker=3D0;
 	int work=3D0;
 	struct z8530_irqhandler *irqs;

commit 742cddc749294be3c0fa909e6255c5a338a1ac40
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 10:37:47 2008 +0100

    fix error path in drivers/net/mlx4/en_rx.c
   =20
    this warning:
   =20
      drivers/net/mlx4/en_rx.c: In function =E2=80=98mlx4_en_activate_r=
x_rings=E2=80=99:
      drivers/net/mlx4/en_rx.c:412: warning: =E2=80=98err=E2=80=99 may =
be used uninitialized in this function
   =20
    Triggers because 'err' is uninitialized in the following input
    conditions: priv->rx_ring_num is zero and mlx4_en_fill_rx_buffers()
    fails.
   =20
    But even if ->rx_ring_num is nonzero, 'err' will be zero if
    mlx4_en_fill_rx_buffers() fails and mlx4_en_activate_rx_rings() ret=
urns
    success - incorrectly.
   =20
    So it's best to keep the error code uptodate on mlx4_en_fill_rx_buf=
fers()
    calls as well.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 6232227..aed7739 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -443,7 +443,8 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *=
priv)
 		/* Fill Rx buffers */
 		ring->full =3D 0;
 	}
-	if (mlx4_en_fill_rx_buffers(priv))
+	err =3D mlx4_en_fill_rx_buffers(priv);
+	if (err)
 		goto err_buffers;
=20
 	for (ring_ind =3D 0; ring_ind < priv->rx_ring_num; ring_ind++) {

commit 181787d1c30af364ffd15428fe6fab7798c3f3c1
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 10:37:35 2008 +0100

    fix warning in drivers/net/cassini.c
   =20
    this warning:
   =20
      drivers/net/cassini.c: In function =E2=80=98cas_rx_ringN=E2=80=99=
:
      drivers/net/cassini.c:2350: warning: =E2=80=98skb=E2=80=99 may be=
 used uninitialized in this function
   =20
    triggers because GCC does not recognize the (correct) error flow
    between cas_rx_process_pkt() and 'skb'.
   =20
    Annotate it.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 86909cf..e083e1c 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2347,7 +2347,7 @@ static int cas_rx_ringN(struct cas *cp, int ring,=
 int budget)
 	drops =3D 0;
 	while (1) {
 		struct cas_rx_comp *rxc =3D rxcs + entry;
-		struct sk_buff *skb;
+		struct sk_buff *uninitialized_var(skb);
 		int type, len;
 		u64 words[4];
 		int i, dring;

commit 96c79254264033f1505198d5d362b68d88d1bbaf
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Oct 17 12:41:30 2008 +0200

    fix warning in net/dccp/options.c
   =20
    this warning:
   =20
      net/dccp/options.c: In function =E2=80=98dccp_parse_options=E2=80=
=99:
      net/dccp/options.c:67: warning: =E2=80=98value=E2=80=99 may be us=
ed uninitialized in this function
   =20
    is a bogus GCC warning. The compiler does not recognize the relatio=
n
    between "value" and "mandatory" variables: the code flow can ever r=
each
    the "out_invalid_option:" label if 'mandatory' is set to 1, and whe=
n
    'mandatory' is non-zero, we'll always have 'value' initialized.
   =20
    Help out the compiler by annotating the variable.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/dccp/options.c b/net/dccp/options.c
index 0809b63..18dcfb9 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -64,7 +64,7 @@ int dccp_parse_options(struct sock *sk, struct dccp_r=
equest_sock *dreq,
 					(dh->dccph_doff * 4);
 	struct dccp_options_received *opt_recv =3D &dp->dccps_options_receive=
d;
 	unsigned char opt, len;
-	unsigned char *value;
+	unsigned char *uninitialized_var(value);
 	u32 elapsed_time;
 	__be32 opt_val;
 	int rc;

commit 193e56a10e56505dc7eac9e5632834c72b55613d
Author: Ingo Molnar <mingo@elte.hu>
Date:   Mon Aug 18 16:18:34 2008 +0200

    fix warning in drivers/net/mlx4/mcg.c
   =20
    fix warning:
   =20
      drivers/net/mlx4/mcg.c: In function =E2=80=98mlx4_multicast_attac=
h=E2=80=99:
      drivers/net/mlx4/mcg.c:217: warning: integer overflow in expressi=
on
   =20
    there was no real danger of overflow here though.
   =20
    md5:
       db8eb55620f886c03854a2abb2ce6c3f  mcg.o.before.asm
       db8eb55620f886c03854a2abb2ce6c3f  mcg.o.after.asm
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/mlx4/mcg.c b/drivers/net/mlx4/mcg.c
index 592c01a..224ef0f 100644
--- a/drivers/net/mlx4/mcg.c
+++ b/drivers/net/mlx4/mcg.c
@@ -215,7 +215,7 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, str=
uct mlx4_qp *qp, u8 gid[16],
=20
 	if (block_mcast_loopback)
 		mgm->qp[members_count++] =3D cpu_to_be32((qp->qpn & MGM_QPN_MASK) |
-						       (1 << MGM_BLCK_LB_BIT));
+						       (1U << MGM_BLCK_LB_BIT));
 	else
 		mgm->qp[members_count++] =3D cpu_to_be32(qp->qpn & MGM_QPN_MASK);
=20

commit bcc35f75a3b9b96c53a74176b135304fc7ffe052
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Oct 17 15:49:15 2008 +0200

    fix warning in net/ax25/sysctl_net_ax25.c
   =20
    fix this warning:
   =20
      net/ax25/sysctl_net_ax25.c:27: warning: =E2=80=98min_ds_timeout=E2=
=80=99 defined but not used
      net/ax25/sysctl_net_ax25.c:27: warning: =E2=80=98max_ds_timeout=E2=
=80=99 defined but not used
   =20
    These are only used in the CONFIG_AX25_DAMA_SLAVE case.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index f288fc4..735ceef 100644
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -24,7 +24,9 @@ static int min_idle[1],			max_idle[] =3D {65535000};
 static int min_n2[] =3D {1},		max_n2[] =3D {31};
 static int min_paclen[] =3D {1},		max_paclen[] =3D {512};
 static int min_proto[1],		max_proto[] =3D { AX25_PROTO_MAX };
+#ifdef CONFIG_AX25_DAMA_SLAVE
 static int min_ds_timeout[1],		max_ds_timeout[] =3D {65535000};
+#endif
=20
 static struct ctl_table_header *ax25_table_header;
=20

commit 59681c6c30e3f700af8d716f66e41ad18f726b80
Author: Ingo Molnar <mingo@elte.hu>
Date:   Mon Oct 20 18:50:11 2008 +0200

    fix warning in net/sunrpc/xprtrdma/verbs.c
   =20
    fix this warning:
   =20
      net/sunrpc/xprtrdma/verbs.c: In function =E2=80=98rpcrdma_conn_up=
call=E2=80=99:
      net/sunrpc/xprtrdma/verbs.c:279: warning: unused variable =E2=80=98=
addr=E2=80=99
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index a5fef5e..900e595 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -276,7 +276,9 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct r=
dma_cm_event *event)
 	struct rpcrdma_xprt *xprt =3D id->context;
 	struct rpcrdma_ia *ia =3D &xprt->rx_ia;
 	struct rpcrdma_ep *ep =3D &xprt->rx_ep;
+#ifdef RPC_DEBUG
 	struct sockaddr_in *addr =3D (struct sockaddr_in *) &ep->rep_remote_a=
ddr;
+#endif
 	struct ib_qp_attr attr;
 	struct ib_qp_init_attr iattr;
 	int connstate =3D 0;

commit ad8d03b315507a954160fcf04dc94cef9f118e77
Author: Ingo Molnar <mingo@elte.hu>
Date:   Mon Oct 20 17:34:02 2008 +0200

    fix warning in net/bluetooth/rfcomm/sock.c
   =20
    fix this warning:
   =20
      net/bluetooth/rfcomm/sock.c: In function =E2=80=98rfcomm_sock_ioc=
tl=E2=80=99:
      net/bluetooth/rfcomm/sock.c:795: warning: unused variable =E2=80=98=
sk=E2=80=99
   =20
    perhaps BT_DEBUG() should be improved to do printf format checking
    instead of the #ifdef, but that looks quite intrusive: each bluetoo=
th
    .c file undefines the macro.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 8a972b6..bc0d4a7 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -792,7 +792,9 @@ static int rfcomm_sock_getsockopt(struct socket *so=
ck, int level, int optname, c
=20
 static int rfcomm_sock_ioctl(struct socket *sock, unsigned int cmd, un=
signed long arg)
 {
+#if defined(CONFIG_BT_RFCOMM_TTY) || defined(CONFIG_BT_RFCOMM_DEBUG)
 	struct sock *sk =3D sock->sk;
+#endif
 	int err;
=20
 	BT_DBG("sk %p cmd %x arg %lx", sk, cmd, arg);

commit 320451a3f79098ca800f2e58674074c26efee020
Author: Ingo Molnar <mingo@elte.hu>
Date:   Sat Oct 18 21:33:06 2008 +0200

    fix warning in drivers/net/wireless/ray_cs.c
   =20
    fix this warning:
   =20
      drivers/net/wireless/ray_cs.c:297: warning: =E2=80=98rcsid=E2=80=99=
 defined but not used
   =20
    'rcsid' is only used in the CONFIG_PROC_FS=3Dy case.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_c=
s.c
index 1404a57..c23a811 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -294,7 +294,9 @@ static char hop_pattern_length[] =3D { 1,
 	     JAPAN_TEST_HOP_MOD
 };
=20
+#ifdef CONFIG_PROC_FS
 static char rcsid[] =3D "Raylink/WebGear wireless LAN - Corey <Thomas =
corey@world.std.com>";
+#endif
=20
 /*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
     ray_attach() creates an "instance" of the driver, allocating

commit decc1656e870c9e5bd94f2357b8496b8da6c2e73
Author: Ingo Molnar <mingo@elte.hu>
Date:   Sat Oct 18 19:14:40 2008 +0200

    fix warning in net/netfilter/nf_conntrack_proto_sctp.c
   =20
    fix this warning:
   =20
      net/netfilter/nf_conntrack_proto_sctp.c: In function =E2=80=98sct=
p_packet=E2=80=99:
      net/netfilter/nf_conntrack_proto_sctp.c:376: warning: array subsc=
ript is above array bounds
   =20
    GCC noticed that new_state could in theory be SCTP_CONNTRACK_MAX,
    which is beyond the limit of the sctp_timeouts[] array.
   =20
    This situation could happen if for_each_sctp_chunk() exits immediat=
ely.
    That should not normally happen - but it's not obvious to me and it=
's
    better to insert an extra check to the end of the loop for this cas=
e.
   =20
    This gets rid of warning as well.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf=
_conntrack_proto_sctp.c
index ae8c260..d31ced4 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -373,6 +373,9 @@ static int sctp_packet(struct nf_conn *ct,
 	}
 	write_unlock_bh(&sctp_lock);
=20
+	if (new_state =3D=3D SCTP_CONNTRACK_MAX)
+		goto out;
+
 	nf_ct_refresh_acct(ct, ctinfo, skb, sctp_timeouts[new_state]);
=20
 	if (old_state =3D=3D SCTP_CONNTRACK_COOKIE_ECHOED &&

commit b547d51a26c5ed23571df50c7254439e2f5dbebe
Author: Ingo Molnar <mingo@elte.hu>
Date:   Sat Oct 18 19:02:37 2008 +0200

    fix warning in net/netfilter/ipvs/ip_vs_ctl.c
   =20
    Impact: fix potential kernel stack information exposure to user-spa=
ce.
   =20
    fix this warning:
   =20
      net/netfilter/ipvs/ip_vs_ctl.c: In function =E2=80=98ip_vs_genl_s=
et_cmd=E2=80=99:
      net/netfilter/ipvs/ip_vs_ctl.c:3034: warning: =E2=80=98t.udp_time=
out=E2=80=99 may be used uninitialized in this function
      net/netfilter/ipvs/ip_vs_ctl.c:3034: note: =E2=80=98t.udp_timeout=
=E2=80=99 was declared here
   =20
    GCC seems to be correct here: in the !CONFIG_IP_VS_PROTO_UDP case
    __ip_vs_get_timeouts keeps the timeout structure uninitialized. But
    in a couple of places we use and copy this structure to user-space,
    potentially exposing kernel-stack data to user-space.
   =20
    While it's a minor issue that only triggers with certain config var=
iations,
    it's best to always initialize this structure in __ip_vs_get_timeou=
ts().
    (GCC will eliminate this memset)
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_=
ctl.c
index 0302cf3..7e3a0c7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2327,6 +2327,7 @@ __ip_vs_get_dest_entries(const struct ip_vs_get_d=
ests *get,
 static inline void
 __ip_vs_get_timeouts(struct ip_vs_timeout_user *u)
 {
+	memset(u, 0, sizeof(*u));
 #ifdef CONFIG_IP_VS_PROTO_TCP
 	u->tcp_timeout =3D
 		ip_vs_protocol_tcp.timeout_table[IP_VS_TCP_S_ESTABLISHED] / HZ;

commit 2281d27663a5f17689ec49e029b4962cba19d614
Author: Ingo Molnar <mingo@elte.hu>
Date:   Sat Oct 18 16:27:37 2008 +0200

    fix warning in drivers/net/atlx/atl2.c
   =20
    fix this warning:
   =20
      drivers/net/atlx/atl2.c: In function =E2=80=98atl2_request_irq=E2=
=80=99:
      drivers/net/atlx/atl2.c:644: warning: unused variable =E2=80=98er=
r=E2=80=99
   =20
    'err' is unused in the !CONFIG_PCI_MSI case.
   =20
    Instead of further increasing the #ifdeffery in this function,
    restructure the code a bit and get rid of the #ifdef. This
    relies on the fact that pci_enable_msi() will always fail in
    the !CONFIG_PCI_MSI case.
   =20
    There should be no change in driver behavior.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 8571e8c..e02bd7e 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -644,7 +644,6 @@ static int atl2_request_irq(struct atl2_adapter *ad=
apter)
 	int flags, err =3D 0;
=20
 	flags =3D IRQF_SHARED;
-#ifdef CONFIG_PCI_MSI
 	adapter->have_msi =3D true;
 	err =3D pci_enable_msi(adapter->pdev);
 	if (err)
@@ -652,7 +651,6 @@ static int atl2_request_irq(struct atl2_adapter *ad=
apter)
=20
 	if (adapter->have_msi)
 		flags &=3D ~IRQF_SHARED;
-#endif
=20
 	return request_irq(adapter->pdev->irq, &atl2_intr, flags, netdev->nam=
e,
 		netdev);

commit b5a7c2b9e1a1b4d80da5d66b330545fdeafe1dad
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Oct 17 19:48:51 2008 +0200

    fix warning in net/netfilter/nf_conntrack_proto_tcp.c
   =20
    fix this warning:
   =20
      net/netfilter/nf_conntrack_proto_tcp.c: In function =E2=80=98tcp_=
in_window=E2=80=99:
      net/netfilter/nf_conntrack_proto_tcp.c:491: warning: unused varia=
ble =E2=80=98net=E2=80=99
      net/netfilter/nf_conntrack_proto_tcp.c: In function =E2=80=98tcp_=
packet=E2=80=99:
      net/netfilter/nf_conntrack_proto_tcp.c:812: warning: unused varia=
ble =E2=80=98net=E2=80=99
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net=
/netfilter/nf_conntrack_l4proto.h
index 7f2f43c..debdaf7 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -129,7 +129,7 @@ extern const struct nla_policy nf_ct_port_nla_polic=
y[];
 	 && net_ratelimit())
 #endif
 #else
-#define LOG_INVALID(net, proto) 0
+static inline int LOG_INVALID(struct net *net, int proto) { return 0; =
}
 #endif /* CONFIG_SYSCTL */
=20
 #endif /*_NF_CONNTRACK_PROTOCOL_H*/

commit 822c18db871bc88b2a60d7a9618ec79a8b5e1ef5
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Oct 17 18:31:33 2008 +0200

    fix warning in drivers/net/wireless/iwlwifi/iwl-scan.c
   =20
    fix this warning:
   =20
      drivers/net/wireless/iwlwifi/iwl-scan.c:92: warning: =E2=80=98iwl=
_escape_essid=E2=80=99 defined but not used
   =20
    Convert the IWL debug macros to proper printf format checking.
    Besides better type checking, this gets rid of the warning as well.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/wireless/iwlwifi/iwl-debug.h b/drivers/net/wir=
eless/iwlwifi/iwl-debug.h
index e548d67..ddc1fbf 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debug.h
+++ b/drivers/net/wireless/iwlwifi/iwl-debug.h
@@ -68,8 +68,10 @@ void iwl_dbgfs_unregister(struct iwl_priv *priv);
 #endif
=20
 #else
-#define IWL_DEBUG(level, fmt, args...)
-#define IWL_DEBUG_LIMIT(level, fmt, args...)
+static inline void __attribute__ ((format(printf, 2, 3)))
+IWL_DEBUG(int level, const char *fmt, ...) { }
+static inline void __attribute__ ((format(printf, 2, 3)))
+IWL_DEBUG_LIMIT(int level, const char *fmt, ...) { }
 #endif				/* CONFIG_IWLWIFI_DEBUG */
=20
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-led.c b/drivers/net/wirel=
ess/iwlwifi/iwl-led.c
index 4eee1b1..f4f0664 100644
--- a/drivers/net/wireless/iwlwifi/iwl-led.c
+++ b/drivers/net/wireless/iwlwifi/iwl-led.c
@@ -43,7 +43,6 @@
 #include "iwl-io.h"
 #include "iwl-helpers.h"
=20
-#ifdef CONFIG_IWLWIFI_DEBUG
 static const char *led_type_str[] =3D {
 	__stringify(IWL_LED_TRG_TX),
 	__stringify(IWL_LED_TRG_RX),
@@ -51,7 +50,6 @@ static const char *led_type_str[] =3D {
 	__stringify(IWL_LED_TRG_RADIO),
 	NULL
 };
-#endif /* CONFIG_IWLWIFI_DEBUG */
=20
=20
 static const struct {

commit 69f38f617c3f832e088be9d35242d929aa623fd4
Author: Ingo Molnar <mingo@elte.hu>
Date:   Wed Aug 27 19:06:48 2008 +0200

    fix warning in drivers/net/depca.c
   =20
    fix warning:
   =20
      drivers/net/depca.c: In function =E2=80=98depca_eisa_probe=E2=80=99=
:
      drivers/net/depca.c:1564: warning: =E2=80=98mem_start=E2=80=99 ma=
y be used uninitialized in this function
   =20
    this seems to be a real bug - depca_eisa_probe() does not check
    for failure. Add it, symmetric to depca_isa_probe().
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index ace39ec..f00bd64 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -1558,6 +1558,7 @@ static int __init depca_isa_probe (struct platfor=
m_device *device)
 #ifdef CONFIG_EISA
 static int __init depca_eisa_probe (struct device *device)
 {
+	enum depca_type adapter =3D unknown;
 	struct eisa_device *edev;
 	struct net_device *dev;
 	struct depca_private *lp;
@@ -1576,7 +1577,11 @@ static int __init depca_eisa_probe (struct devic=
e *device)
 	 * the EISA configuration structures (yet... :-), just rely on
 	 * the ISA probing to sort it out... */
=20
-	depca_shmem_probe (&mem_start);
+	adapter =3D depca_shmem_probe (&mem_start);
+	if (adapter =3D=3D unknown) {
+		status =3D -ENODEV;
+		goto out_free;
+	}
=20
 	dev->base_addr =3D ioaddr;
 	dev->irq =3D irq;

commit 557073e3dac7b8479df69c140a5fd2b8f4a9cfad
Author: Ingo Molnar <mingo@elte.hu>
Date:   Wed Aug 27 19:05:19 2008 +0200

    fix warning in drivers/net/3c523.c
   =20
    fix warning:
   =20
      drivers/net/3c523.c:582: warning: =E2=80=98cleanup_card=E2=80=99 =
defined but not used
   =20
    No code changed:
   =20
    md5:
       ebe4a1b27d3f21b0b12a78c58463b0d7  3c523.o.before.asm
       ebe4a1b27d3f21b0b12a78c58463b0d7  3c523.o.after.asm
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index e2ce41d..7b9d427 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -578,13 +578,13 @@ err_out:
 	return retval;
 }
=20
+#ifdef MODULE
 static void cleanup_card(struct net_device *dev)
 {
 	mca_set_adapter_procfn(((struct priv *) (dev->priv))->slot, NULL, NUL=
L);
 	release_region(dev->base_addr, ELMC_IO_EXTENT);
 }
-
-#ifndef MODULE
+#else
 struct net_device * __init elmc_probe(int unit)
 {
 	struct net_device *dev =3D alloc_etherdev(sizeof(struct priv));

commit d138e44e2f8d0f26e04b0386d328d9cc7e33d82e
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Oct 17 14:30:37 2008 +0200

    drivers/net/wireless/b43/phy_g.c: type check debug printouts
   =20
    this warning:
   =20
      drivers/net/wireless/b43/phy_g.c: In function =E2=80=98b43_gphy_o=
p_recalc_txpower=E2=80=99:
      drivers/net/wireless/b43/phy_g.c:3191: warning: unused variable =E2=
=80=98dbm=E2=80=99
   =20
    is caused because b43dbg() is a macro, hence in the !B43_DEBUG
    case the compiler does not know that the variables are used.
   =20
    Convert it to a proper inline instead. This also improves type chec=
king
    in the !B43_DEBUG case.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/=
b43.h
index 427b820..ac55b62 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -853,7 +853,8 @@ void b43warn(struct b43_wl *wl, const char *fmt, ..=
=2E)
 void b43dbg(struct b43_wl *wl, const char *fmt, ...)
     __attribute__ ((format(printf, 2, 3)));
 #else /* DEBUG */
-# define b43dbg(wl, fmt...) do { /* nothing */ } while (0)
+static inline void __attribute__ ((format(printf, 2, 3)))
+b43dbg(struct b43_wl *wl, const char *fmt, ...) { }
 #endif /* DEBUG */
=20
 /* A WARN_ON variant that vanishes when b43 debugging is disabled.

commit 7e4f7889aca92f2cf95ba31e005fc1368c1cbc5a
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Oct 17 17:47:04 2008 +0200

    fix warning in drivers/net/sky2.c
   =20
    fix this warning:
   =20
      drivers/net/sky2.c: In function =E2=80=98sky2_mhz=E2=80=99:
      drivers/net/sky2.c:2753: warning: control reaches end of non-void=
 function
   =20
    BUG() can be NOP on !CONFIG_BUG.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 3813d15..85fdacc 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2748,7 +2748,7 @@ static u32 sky2_mhz(const struct sky2_hw *hw)
 		return 156;
=20
 	default:
-		BUG();
+		panic("sky2_mhz: unknown chip id!");
 	}
 }
=20

commit deb797f96d920083ba8a0bcfa6f57b19fc593571
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Oct 17 17:34:27 2008 +0200

    fix warning in net/sunrpc/svcauth_unix.c
   =20
    fix this warning:
   =20
      net/sunrpc/svcauth_unix.c: In function =E2=80=98svcauth_unix_set_=
client=E2=80=99:
      net/sunrpc/svcauth_unix.c:681: warning: =E2=80=98sin6=E2=80=99 ma=
y be used uninitialized in this function
   =20
    caused by BUG() being a NOP on !CONFIG_BUG.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index f24800f..200ed93 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -692,7 +692,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 		sin6 =3D svc_addr_in6(rqstp);
 		break;
 	default:
-		BUG();
+		panic("svcauth_unix_set_client: bad address family!");
 	}
=20
 	rqstp->rq_client =3D NULL;
@@ -873,3 +873,4 @@ struct auth_ops svcauth_unix =3D {
 	.set_client	=3D svcauth_unix_set_client,
 };
=20
+

commit 923a5a960577dcc5189b6113300a122c0212b292
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Oct 17 16:55:34 2008 +0200

    fix warning in security/selinux/netnode.c
   =20
    fix this warning:
   =20
      security/selinux/netnode.c: In function =E2=80=98sel_netnode_find=
=E2=80=99:
      security/selinux/netnode.c:131: warning: =E2=80=98idx=E2=80=99 ma=
y be used uninitialized in this function
   =20
    BUG() can be a NOP in the !CONFIG_BUG case. Return NULL in that cas=
e,
    instead of running in an undefined way.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/security/selinux/netnode.c b/security/selinux/netnode.c
index 7100072..a307122 100644
--- a/security/selinux/netnode.c
+++ b/security/selinux/netnode.c
@@ -140,6 +140,7 @@ static struct sel_netnode *sel_netnode_find(const v=
oid *addr, u16 family)
 		break;
 	default:
 		BUG();
+		return NULL;
 	}
=20
 	list_for_each_entry_rcu(node, &sel_netnode_hash[idx].list, list)

commit c62cda5dfaf7630edefe097a3e23af7732060b08
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Oct 17 16:26:02 2008 +0200

    fix warning in net/packet/af_packet.c
   =20
    fix this warning:
   =20
      net/packet/af_packet.c: In function =E2=80=98tpacket_rcv=E2=80=99=
:
      net/packet/af_packet.c:604: warning: =E2=80=98hdrlen=E2=80=99 may=
 be used uninitialized in this function
   =20
    This is because in the !CONFIG_BUG case BUG() is a NOP.
   =20
    There is no other sane way to continue but to panic the system
    unconditionally, regardless of the CONFIG_BUG setting.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c718e7e..1478fb8 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -709,7 +709,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct =
net_device *dev, struct packe
 		hdrlen =3D sizeof(*h.h2);
 		break;
 	default:
-		BUG();
+		panic("AF_PACKET: bad tp->version");
 	}
=20
 	sll =3D h.raw + TPACKET_ALIGN(hdrlen);

commit d581867031ebe3c6f4e018ea32ed8b9ee5141ead
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Oct 17 16:15:59 2008 +0200

    fix warning in net/rfkill/rfkill.c
   =20
    fix this warning:
   =20
      net/rfkill/rfkill.c: In function =E2=80=98rfkill_get_type_str=E2=80=
=99:
      net/rfkill/rfkill.c:393: warning: control reaches end of non-void=
 function
   =20
    in the embedded !CONFIG_BUG case BUG() is a NOP.
   =20
    Return NULL to solve this (unlikely) scenario. All callers feed thi=
s
    pointer into sprintf %s so NULL should be fine.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index f949a48..eecb9a8 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -389,6 +389,7 @@ static const char *rfkill_get_type_str(enum rfkill_=
type type)
 		return "wwan";
 	default:
 		BUG();
+		return NULL;
 	}
 }
=20

--
To unsubscribe from this list: send the line "unsubscribe linux-crypto"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
