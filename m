From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH net 3/7] openvswitch: Fix skb leak in ovs_fragment()
Date: Tue, 29 Sep 2015 22:48:56 +0000
Message-ID: <55E40A4D-8CE1-4433-9BB0-43CB41021BA1@intel.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
 <1443566380-22640-4-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_BA95ECFC-B11B-4B4E-B4CE-0710A46764CA";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:21609 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751031AbbI2Ws6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 18:48:58 -0400
In-Reply-To: <1443566380-22640-4-git-send-email-joestringer@nicira.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_BA95ECFC-B11B-4B4E-B4CE-0710A46764CA
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Sep 29, 2015, at 3:39 PM, Joe Stringer <joestringer@nicira.com> =
wrote:
>=20
> @@ -728,8 +727,14 @@ static void ovs_fragment(struct vport *vport, =
struct sk_buff *skb, u16 mru,
> 		WARN_ONCE(1, "Failed fragment ->%s: eth=3D%04x, MRU=3D%d, =
MTU=3D%d.",
> 			  ovs_vport_name(vport), ntohs(ethertype), mru,
> 			  vport->dev->mtu);
> -		kfree_skb(skb);
> +		goto out;
> 	}
> +
> +	skb =3D NULL;
> +
> +out:
> +	if (skb)
> +		kfree_skb(skb);
> }
>=20
> static void do_output(struct datapath *dp, struct sk_buff *skb, int =
out_port,

Wouldn't that hunk be better as:

@@ -728,8 +727,13 @@ static void ovs_fragment(struct vport *vport, =
struct sk_buff *skb, u16 mru,
		WARN_ONCE(1, "Failed fragment ->%s: eth=3D%04x, MRU=3D%d, =
MTU=3D%d.",
			  ovs_vport_name(vport), ntohs(ethertype), mru,
			  vport->dev->mtu);
-		kfree_skb(skb);
+		goto out;
	}
+
+	return;
+
+out:
+	kfree_skb(skb);
}

static void do_output(struct datapath *dp, struct sk_buff *skb, int =
out_port,

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_BA95ECFC-B11B-4B4E-B4CE-0710A46764CA
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWCxVXAAoJEDwO/+eO4+5u/RMP/iIK5L0FRjna4opcl08SuBdT
QHUF8m4UZywqWT81mfX6plEtH/UbwBw/IqkrA5xJFHKK+TxLmtBdKWnOwQllSQIR
knZrROgE7RoYNPWeDHupKK4EyKKX+FjfOKvEwLADF8mGxW2JwOKuBeFJfPFD43Jr
7vtNK0vG3Fv4cayyF7vBJcomTT7iKjhFj7NZcFn+G4Ag16PMT+ltZpJsPPCjGzd/
oM5tCp1zG4s3jERgR3k8pL+6ugNGLoU2tDHG5BYX5InvyR7KV+ubP5fySVeuwgxL
HijqcY5S+P1iH8kPXP8zJkb4uk+ESq/CVM0JgXtycNUZWxYN+bv74gxef0B6JESh
WbNvc/HvyF2cLPsk464lCPrA5ONaPmwnjLOlTt7q1/z3kj1t1HJExCAvFuoiVL6V
lGSuk86Q4/6G9aZ8/LpV0qgJngXo3fFChDfZNgFb0Qxe2SXq6AWTUM3ziAy7oEJe
c9BleynEr/1BBdF2j/uSA3DV+ilyEZTVVJ+hRzP0182R28qZuWGsS/6m7wL2BANH
Vn+vDuAZdo3V5zJeHtgOeC0Rizjdg4goMCn0qrRx7yVur6sx/km5QNnzAL5epArA
52AWwc08Z/mSc+hem7rnKahmFXg1ulH7NU+D07t2L47XzlR3a1eVmKhxmRoQRoEw
YDj4jlmr0QB3I+7wBkA0
=u2tb
-----END PGP SIGNATURE-----

--Apple-Mail=_BA95ECFC-B11B-4B4E-B4CE-0710A46764CA--
