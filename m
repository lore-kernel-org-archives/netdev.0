From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: pull request for net: batman-adv 2013-06-11
Date: Tue, 11 Jun 2013 10:07:35 +0200
Message-ID: <20130611080735.GA1466@ritirata.org>
References: <1370932501-3937-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature"; boundary="FCuugMFkClbJLl1L"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1370932501-3937-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello David,

On Tue, Jun 11, 2013 at 08:34:58AM +0200, Antonio Quartulli wrote:

[...]

>=20
>=20
> Please pull or let me know if there is any problem!

After having applied this patchset the merge of net into net-next will gene=
rate
a conflict. Here you have the needed information to properly solve it.

Regards,



conflict in net/batman-adv/bat_iv_ogm.c:

++<<<<<<< HEAD
 + * batadv_ring_buffer_set - update the ring buffer with the given value
 + * @lq_recv: pointer to the ring buffer
 + * @lq_index: index to store the value at
 + * @value: value to store in the ring buffer
 + */
 +static void batadv_ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index,
 +				   uint8_t value)
 +{
 +	lq_recv[*lq_index] =3D value;
 +	*lq_index =3D (*lq_index + 1) % BATADV_TQ_GLOBAL_WINDOW_SIZE;
 +}
 +
 +/**
 + * batadv_ring_buffer_set - compute the average of all non-zero values st=
ored
 + * in the given ring buffer
 + * @lq_recv: pointer to the ring buffer
 + *
 + * Returns computed average value.
 + */
 +static uint8_t batadv_ring_buffer_avg(const uint8_t lq_recv[])
 +{
 +	const uint8_t *ptr;
 +	uint16_t count =3D 0, i =3D 0, sum =3D 0;
 +
 +	ptr =3D lq_recv;
 +
 +	while (i < BATADV_TQ_GLOBAL_WINDOW_SIZE) {
 +		if (*ptr !=3D 0) {
 +			count++;
 +			sum +=3D *ptr;
 +		}
 +
 +		i++;
 +		ptr++;
 +	}
 +
 +	if (count =3D=3D 0)
 +		return 0;
 +
 +	return (uint8_t)(sum / count);
 +}
++=3D=3D=3D=3D=3D=3D=3D
+  * batadv_dup_status - duplicate status
+  * @BATADV_NO_DUP: the packet is a duplicate
+  * @BATADV_ORIG_DUP: OGM is a duplicate in the originator (but not for the
+  *  neighbor)
+  * @BATADV_NEIGH_DUP: OGM is a duplicate for the neighbor
+  * @BATADV_PROTECTED: originator is currently protected (after reboot)
+  */
+ enum batadv_dup_status {
+ 	BATADV_NO_DUP =3D 0,
+ 	BATADV_ORIG_DUP,
+ 	BATADV_NEIGH_DUP,
+ 	BATADV_PROTECTED,
+ };
+=20
++>>>>>>> 7c24bbb... batman-adv: forward late OGMs from best next hop

is solved as follows (add /** at the top of the batadv_dup_status kerneldoc=
 and
keep everything):

<<<<<<<<<<<<
 * batadv_ring_buffer_set - update the ring buffer with the given value
 * @lq_recv: pointer to the ring buffer
 * @lq_index: index to store the value at
 * @value: value to store in the ring buffer
 */
static void batadv_ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index,
				   uint8_t value)
{
	lq_recv[*lq_index] =3D value;
	*lq_index =3D (*lq_index + 1) % BATADV_TQ_GLOBAL_WINDOW_SIZE;
}

/**
 * batadv_ring_buffer_set - compute the average of all non-zero values stor=
ed
 * in the given ring buffer
 * @lq_recv: pointer to the ring buffer
 *
 * Returns computed average value.
 */
static uint8_t batadv_ring_buffer_avg(const uint8_t lq_recv[])
{
	const uint8_t *ptr;
	uint16_t count =3D 0, i =3D 0, sum =3D 0;

	ptr =3D lq_recv;

	while (i < BATADV_TQ_GLOBAL_WINDOW_SIZE) {
		if (*ptr !=3D 0) {
			count++;
			sum +=3D *ptr;
		}

		i++;
		ptr++;
	}

	if (count =3D=3D 0)
		return 0;

	return (uint8_t)(sum / count);
}

/**
 * batadv_dup_status - duplicate status
 * @BATADV_NO_DUP: the packet is a duplicate
 * @BATADV_ORIG_DUP: OGM is a duplicate in the originator (but not for the
 *  neighbor)
 * @BATADV_NEIGH_DUP: OGM is a duplicate for the neighbor
 * @BATADV_PROTECTED: originator is currently protected (after reboot)
 */
enum batadv_dup_status {
	BATADV_NO_DUP =3D 0,
	BATADV_ORIG_DUP,
	BATADV_NEIGH_DUP,
	BATADV_PROTECTED,
};

>>>>>>>>>>>>>>

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--FCuugMFkClbJLl1L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRttrHAAoJEADl0hg6qKeOtY8QAMQmA/ZGoX2AqodeOGNG0+M5
y1cm2v/BI0+44/n8fJYphJIhmBYn1MthQNot1jgCNPIxmNVJfFt6JIqGRVYbnhI5
vWdqgEEq50HI3N9VMPn8ehMiIcyyDacVMX4QpiO4Q3z2y1+2YksD2mCZNsmLu/KF
vLfwHRL88RsZfcnEHT4vRseJ6PFSyfLNtH5Yx2AgTQwUkwshIncPKn/eLr66glox
hCmXftVIXyAyGQW1+5zM9UNGtRo/n2J0H7JShmOPPw1Dsa9l5GaEKWcYF3o1Mzfm
SHjroYXLMcsMdzUgjUxm7gy5lJB5LFnj2XcJh8JZVgo/q6vuLWfCcqWA/AKG4ZwM
AFMsUbAM9aTOWiPRyahiyo02e+Lze63o1sfGhHHKJmHAsHPQyTmfI8q73igammiE
Rsloko0bIpOFGq7E7JFbuvbyF26Gss3LPZVQKgUmQTjqyV/6GyS/9Umg1OTOnkDg
BGSegUU/jdXuGAfyM1F4wemQ3kvgaM1WvNI7cMzYBTf2OeDJGhYw2Ghp9nEH0SF4
RLcXeZ3hUMG90zVISbhdIHEb90bD3RFDcHbZIQse7OgHDc3oP/Z/bHjHi358St4f
GJbHiwXJtUe9pPw156pqJhRvpwEE/vcNLMRo3aaLGiHkxyyy2fIKAyKRsf5cMnrK
s9jQtJUZwjcP6TTPPAkF
=8u65
-----END PGP SIGNATURE-----

--FCuugMFkClbJLl1L--
