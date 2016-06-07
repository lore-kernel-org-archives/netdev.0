From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/3] bridge: netfilter: checkpatch whitespace fixes
Date: Tue, 07 Jun 2016 11:02:30 -0700
Message-ID: <1465322550.25087.40.camel@perches.com>
References: <1462843618-21914-1-git-send-email-me@tobin.cc>
	 <1462843618-21914-2-git-send-email-me@tobin.cc>
	 <20160607151458.GA18008@salvia> <1465319080.25087.28.camel@perches.com>
	 <20160607173417.GA1141@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tcharding <me@tobin.cc>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160607173417.GA1141@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-06-07 at 19:34 +0200, Pablo Neira Ayuso wrote:
> On Tue, Jun 07, 2016 at 10:04:40AM -0700, Joe Perches wrote:
> > One more question, is this chunk below correct from
> > coding style point of view?
>=20
> =A0=A0=A0=A0=A0=A0=A0=A0if (info->bitmask & EBT_STP_ROOTADDR) {
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0verdict =3D 0;
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0for (i =3D 0; i < 6; =
i++)
> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
verdict |=3D (stpc->root[2+i] ^ c->root_addr[i]) &
> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0c->root_addrmsk[i];
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
verdict |=3D (stpc->root[2 + i] ^ c->root_addr[i]) &
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0c->root_addrmsk[i];
>=20
> I think the previous line is fine.

"2+i" or "2 + i", either is OK.
Multiple line statement alignment doesn't
matter much.

I think either is fine and both are "don't care, don't need"
to change from one to another to satisfy some silly whitespace
overlord brainless script.

Perhaps it's better to add a function for this though.

Something like:
---
=A0net/bridge/netfilter/ebt_stp.c | 60 +++++++++++++++++++++++---------=
----------
=A01 file changed, 33 insertions(+), 27 deletions(-)

diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_=
stp.c
index 6b731e1..4096fac 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -40,13 +40,24 @@ struct stp_config_pdu {
=A0#define NR16(p) (p[0] << 8 | p[1])
=A0#define NR32(p) ((p[0] << 24) | (p[1] << 16) | (p[2] << 8) | p[3])
=A0
+static bool ebt_test_addr(const uint8_t *root, const char *addr,
+			=A0=A0const char *mask)
+{
+	bool rtn =3D false;
+	int i;
+
+	for (i =3D 0; i < ETH_ALEN; i++)
+		rtn |=3D (root[2 + i] ^ addr[i]) & mask[i];
+
+	return rtn;
+}
+
=A0static bool ebt_filter_config(const struct ebt_stp_info *info,
=A0			=A0=A0=A0=A0=A0=A0const struct stp_config_pdu *stpc)
=A0{
=A0	const struct ebt_stp_config_info *c;
=A0	uint16_t v16;
=A0	uint32_t v32;
-	int verdict, i;
=A0
=A0	c =3D &info->config;
=A0	if ((info->bitmask & EBT_STP_FLAGS) &&
@@ -54,66 +65,61 @@ static bool ebt_filter_config(const struct ebt_stp_=
info *info,
=A0		return false;
=A0	if (info->bitmask & EBT_STP_ROOTPRIO) {
=A0		v16 =3D NR16(stpc->root);
-		if (FWINV(v16 < c->root_priol ||
-		=A0=A0=A0=A0v16 > c->root_priou, EBT_STP_ROOTPRIO))
+		if (FWINV(v16 < c->root_priol || v16 > c->root_priou,
+			=A0=A0EBT_STP_ROOTPRIO))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_ROOTADDR) {
-		verdict =3D 0;
-		for (i =3D 0; i < 6; i++)
-			verdict |=3D (stpc->root[2+i] ^ c->root_addr[i]) &
-				=A0=A0=A0c->root_addrmsk[i];
-		if (FWINV(verdict !=3D 0, EBT_STP_ROOTADDR))
+		if (FWINV(ebt_test_addr(stpc->root, c->root_addr,
+					c->root_addrmsk),
+			=A0=A0EBT_STP_ROOTADDR))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_ROOTCOST) {
=A0		v32 =3D NR32(stpc->root_cost);
-		if (FWINV(v32 < c->root_costl ||
-		=A0=A0=A0=A0v32 > c->root_costu, EBT_STP_ROOTCOST))
+		if (FWINV(v32 < c->root_costl || v32 > c->root_costu,
+			=A0=A0EBT_STP_ROOTCOST))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_SENDERPRIO) {
=A0		v16 =3D NR16(stpc->sender);
-		if (FWINV(v16 < c->sender_priol ||
-		=A0=A0=A0=A0v16 > c->sender_priou, EBT_STP_SENDERPRIO))
+		if (FWINV(v16 < c->sender_priol || v16 > c->sender_priou,
+			=A0=A0EBT_STP_SENDERPRIO))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_SENDERADDR) {
-		verdict =3D 0;
-		for (i =3D 0; i < 6; i++)
-			verdict |=3D (stpc->sender[2+i] ^ c->sender_addr[i]) &
-				=A0=A0=A0c->sender_addrmsk[i];
-		if (FWINV(verdict !=3D 0, EBT_STP_SENDERADDR))
+		if (FWINV(ebt_test_addr(stpc->sender, c->sender_addr,
+					c->sender_addrmsk),
+			=A0=A0EBT_STP_SENDERADDR))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_PORT) {
=A0		v16 =3D NR16(stpc->port);
-		if (FWINV(v16 < c->portl ||
-		=A0=A0=A0=A0v16 > c->portu, EBT_STP_PORT))
+		if (FWINV(v16 < c->portl || v16 > c->portu, EBT_STP_PORT))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_MSGAGE) {
=A0		v16 =3D NR16(stpc->msg_age);
-		if (FWINV(v16 < c->msg_agel ||
-		=A0=A0=A0=A0v16 > c->msg_ageu, EBT_STP_MSGAGE))
+		if (FWINV(v16 < c->msg_agel || v16 > c->msg_ageu,
+			=A0=A0EBT_STP_MSGAGE))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_MAXAGE) {
=A0		v16 =3D NR16(stpc->max_age);
-		if (FWINV(v16 < c->max_agel ||
-		=A0=A0=A0=A0v16 > c->max_ageu, EBT_STP_MAXAGE))
+		if (FWINV(v16 < c->max_agel || v16 > c->max_ageu,
+			=A0=A0EBT_STP_MAXAGE))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_HELLOTIME) {
=A0		v16 =3D NR16(stpc->hello_time);
-		if (FWINV(v16 < c->hello_timel ||
-		=A0=A0=A0=A0v16 > c->hello_timeu, EBT_STP_HELLOTIME))
+		if (FWINV(v16 < c->hello_timel || v16 > c->hello_timeu,
+			=A0=A0EBT_STP_HELLOTIME))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_FWDD) {
=A0		v16 =3D NR16(stpc->forward_delay);
-		if (FWINV(v16 < c->forward_delayl ||
-		=A0=A0=A0=A0v16 > c->forward_delayu, EBT_STP_FWDD))
+		if (FWINV(v16 < c->forward_delayl || v16 > c->forward_delayu,
+			=A0=A0EBT_STP_FWDD))
=A0			return false;
=A0	}
=A0	return true;

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
