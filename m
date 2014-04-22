From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: [PATCH 3.13] core, nfqueue,
 openvswitch: Orphan frags in skb_zerocopy and handle errors
Date: Tue, 22 Apr 2014 20:18:04 +0100
Message-ID: <1398194284.7767.101.camel@deadeye.wl.decadent.org.uk>
References: <1395873465-22282-1-git-send-email-zoltan.kiss@citrix.com>
 <20140327.152956.1528740039185894234.davem@davemloft.net>
 <20140421112601.GC3200@hercules>
 <1398181118.3624.203.camel@deadeye.wl.decadent.org.uk>
 <5356AEBF.5010505@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3130513243993457521=="
Cc: netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mszeredi-AlSwsSmVLrQ@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, JBeulich-IBi9RG/b67k@public.gmane.org,
 therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
 Luis Henriques <luis.henriques-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
 xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org,
 Paul.Durrant-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <5356AEBF.5010505-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org


--===============3130513243993457521==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Vv0pKuM1AUvurcOJjlxB"


--=-Vv0pKuM1AUvurcOJjlxB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

From: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>

commit 36d5fe6a000790f56039afe26834265db0a3ad4c upstream.

skb_zerocopy can copy elements of the frags array between skbs, but it does=
n't
orphan them. Also, it doesn't handle errors, so this patch takes care of th=
at
as well, and modify the callers accordingly. skb_tx_error() is also added t=
o
the callers so they will signal the failed delivery towards the creator of =
the
skb.

Signed-off-by: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
[bwh: Backported to 3.13: skb_zerocopy() is new in 3.14, but was moved from=
 a
 static function in nfnetlink_queue.  We need to patch that and its caller,=
 but
 not openvswitch.]
Signed-off-by: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
---
On Tue, 2014-04-22 at 19:02 +0100, Zoltan Kiss wrote:
> On 22/04/14 16:38, Ben Hutchings wrote:
> > On Mon, 2014-04-21 at 12:26 +0100, Luis Henriques wrote:
> >> Hi David,
> >>
> >> On Thu, Mar 27, 2014 at 03:29:56PM -0400, David Miller wrote:
> >>> From: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
> >>> Date: Wed, 26 Mar 2014 22:37:45 +0000
> >>>
> >>>> skb_zerocopy can copy elements of the frags array between skbs, but =
it doesn't
> >>>> orphan them. Also, it doesn't handle errors, so this patch takes car=
e of that
> >>>> as well, and modify the callers accordingly. skb_tx_error() is also =
added to
> >>>> the callers so they will signal the failed delivery towards the crea=
tor of the
> >>>> skb.
> >>>>
> >>>> Signed-off-by: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
> >>>
> >>> Fingers crossed :-)  Applied, thanks Zoltan.
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >> Could you please queue this for stable as well?  It has CVE-2014-2568
> >> assigned to it and I believe it is applicable to some of the trees.
> >
> > It was applied to 3.13, but needs backporting to earlier versions.  I
> > posted my attempt in
> > <1397429860.10849.86.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org> but it needs
> > testing/reviewing.
>=20
> This one is a different issue, although it is very similar.

Sorry for mixing these up.  I believe this bug has been present since
zerocopy was added to nfqueue in Linux 3.10 (commit ae08ce002108).  This
is the version I used for Debian's 3.13 branch, which might be usable
for older stable branches too.

Ben.

---
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -235,22 +235,23 @@ nfqnl_flush(struct nfqnl_instance *queue
 	spin_unlock_bh(&queue->lock);
 }
=20
-static void
+static int
 nfqnl_zcopy(struct sk_buff *to, const struct sk_buff *from, int len, int h=
len)
 {
 	int i, j =3D 0;
 	int plen =3D 0; /* length of skb->head fragment */
+	int ret;
 	struct page *page;
 	unsigned int offset;
=20
 	/* dont bother with small payloads */
-	if (len <=3D skb_tailroom(to)) {
-		skb_copy_bits(from, 0, skb_put(to, len), len);
-		return;
-	}
+	if (len <=3D skb_tailroom(to))
+		return skb_copy_bits(from, 0, skb_put(to, len), len);
=20
 	if (hlen) {
-		skb_copy_bits(from, 0, skb_put(to, hlen), hlen);
+		ret =3D skb_copy_bits(from, 0, skb_put(to, hlen), hlen);
+		if (unlikely(ret))
+			return ret;
 		len -=3D hlen;
 	} else {
 		plen =3D min_t(int, skb_headlen(from), len);
@@ -268,6 +269,11 @@ nfqnl_zcopy(struct sk_buff *to, const st
 	to->len +=3D len + plen;
 	to->data_len +=3D len + plen;
=20
+	if (unlikely(skb_orphan_frags(from, GFP_ATOMIC))) {
+		skb_tx_error(from);
+		return -ENOMEM;
+	}
+
 	for (i =3D 0; i < skb_shinfo(from)->nr_frags; i++) {
 		if (!len)
 			break;
@@ -278,6 +284,8 @@ nfqnl_zcopy(struct sk_buff *to, const st
 		j++;
 	}
 	skb_shinfo(to)->nr_frags =3D j;
+
+	return 0;
 }
=20
 static int
@@ -374,13 +382,16 @@ nfqnl_build_packet_message(struct net *n
=20
 	skb =3D nfnetlink_alloc_skb(net, size, queue->peer_portid,
 				  GFP_ATOMIC);
-	if (!skb)
+	if (!skb) {
+		skb_tx_error(entskb);
 		return NULL;
+	}
=20
 	nlh =3D nlmsg_put(skb, 0, 0,
 			NFNL_SUBSYS_QUEUE << 8 | NFQNL_MSG_PACKET,
 			sizeof(struct nfgenmsg), 0);
 	if (!nlh) {
+		skb_tx_error(entskb);
 		kfree_skb(skb);
 		return NULL;
 	}
@@ -504,13 +515,15 @@ nfqnl_build_packet_message(struct net *n
 		nla->nla_type =3D NFQA_PAYLOAD;
 		nla->nla_len =3D nla_attr_size(data_len);
=20
-		nfqnl_zcopy(skb, entskb, data_len, hlen);
+		if (nfqnl_zcopy(skb, entskb, data_len, hlen))
+			goto nla_put_failure;
 	}
=20
 	nlh->nlmsg_len =3D skb->len;
 	return skb;
=20
 nla_put_failure:
+	skb_tx_error(entskb);
 	kfree_skb(skb);
 	net_err_ratelimited("nf_queue: error creating packet message\n");
 	return NULL;

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-Vv0pKuM1AUvurcOJjlxB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIUAwUAU1bAbOe/yOyVhhEJAQomXw/41oNtg+4/VhTYXH8KRy6ZJTszBaTKJOJA
nliM1dunH40tnT6dPtfsqMPiqHX4LAsprABSpUNXt7JvryPYTqzeM121YirhUtfi
7OMdY/N3x11c2zi+8av16Ia6ccVqFUhOoRIlKPYlJI9CPwIB4m+TtLWRiesKUU+m
oh+llBUYRnXhCaZI5Fi4ZkBBfFLnmoaF7hp7Uz4VvjKJFMvAZ8fEAtb4dzSt1upH
IfpIaANPVVAyYy/yAOine8xfxFDaWbMcrTWlJazIzJvqfQGfL0IBql0PFpGW4tki
C0Od6hExVtO7cCIiHw3KXQgjUiR4VbykVqi1xAU9a9K6WeimbCMZJumdauSZEw+1
/CZgr/GWj7kbWCDiZJG3fFK0SQEvC5YcwfWN/ZlmTA13mAseN5R8V2cF7Neki1ZD
KoFiypUHFIpWpGf/BKuaYsafCyd+MoaPvYhzK+G5kIdXFvvlSTQmq57L6y4HyZXp
6YyR4/K+IXaEWK8yJuIf9lzobKzPsEogNVq5qqazv0P1kXWLnKGVJMuq55KEVLqE
S2EouZjinfleE571va9hyEo05n3yUPulyaZ8JqteLl1xQWMhlVPQ3+P655lz5fEu
kdOmZbwe2fxqNsb2i+4f3ABHWWprt7KIgUgNli7SiOsMyOspGmekHOdrWUzl41yC
HjRBM7IEyw==
=B9oh
-----END PGP SIGNATURE-----

--=-Vv0pKuM1AUvurcOJjlxB--

--===============3130513243993457521==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============3130513243993457521==--
