From: Antonio Quartulli <antonio@open-mesh.com>
Subject: Re: [PATCH] skbedit: allow the user to specify bitmask for mark
Date: Mon, 21 Jul 2014 14:08:45 +0200
Message-ID: <53CD02CD.7050300@open-mesh.com>
References: <1405931720-24383-1-git-send-email-antonio@meshcoding.com> <53CD01E7.50004@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="hLm5PKjcgVKexwMJ7SQliGjBSCHqdMfe0"
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dev-nolb.cloudtrax.com ([54.203.245.161]:35088 "EHLO
	dev-nolb.cloudtrax.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754854AbaGUMSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 08:18:32 -0400
In-Reply-To: <53CD01E7.50004@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--hLm5PKjcgVKexwMJ7SQliGjBSCHqdMfe0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable



On 21/07/14 14:04, Sergei Shtylyov wrote:
>> diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
>> index fcfeeaf..5fca32b 100644
>> --- a/net/sched/act_skbedit.c
>> +++ b/net/sched/act_skbedit.c
>> @@ -43,8 +43,12 @@ static int tcf_skbedit(struct sk_buff *skb, const
>> struct tc_action *a,
>>       if (d->flags & SKBEDIT_F_QUEUE_MAPPING &&
>>           skb->dev->real_num_tx_queues > d->queue_mapping)
>>           skb_set_queue_mapping(skb, d->queue_mapping);
>> -    if (d->flags & SKBEDIT_F_MARK)
>> -        skb->mark =3D d->mark;
>> +    if (d->flags & SKBEDIT_F_MARK) {
>> +        /* unset all the bits in the mask */
>> +        skb->mark =3D skb->mark & ~d->mask;
>=20
>    Why not 'skb->mark &=3D ~d->mask;'?


No real reason :) Shall we always use the compressed version of this
operator when possible ?


--=20
Antonio Quartulli


--hLm5PKjcgVKexwMJ7SQliGjBSCHqdMfe0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJTzQLRAAoJEJgn97Bh2u9eh5sQAMD7cJGu6cUs57MiK58bIZGx
RZyXDj7W4eLIo0cfvJD1XULhm+M9v9xOl1+IawyxUHVMvOisKn/m+ZR+XOdGWYZJ
JWW6A3kFDtLf3IefDGP5sicW8ri77cQ+ii0It9nXuwY6veMaMMM1S3WT8ktsBvmJ
DZ2pEnI46M+HG38gKHeIyCEzhz0q4K6tnAIf8uKOf5Gk7tKglIVtfhlh7R2MRKZt
tJISKcvYrTlL9NA+KgfPDPPuYFqDyH2JdQFEzhDWaFUfeZx/b6GTAFCyCxUx2MF3
/tQbvTqDVJB29UztOmQ8qbNfEEZbT2/qqtquYvXJE0ys4qULyuepy+BbEekeR7SQ
PaIKi/Txryp0LEg3GZwHRVZrMVXSviM2Y0eZKn4/RueIlld3yk/qROrMsMo21rAI
Ju7236FoSv3WgSYlYZ6rjh4QMb4eDOf0Heqek+UrsdfkP6oUR6cArhoxfz2n8XTA
54E+JGGshJqwoTY+qRbfV3826lD3RSHxDrRU0XgFkfKk+WvnZZcHGK0SRgTTtDUw
HMt4xpWR0VyxhyulEOXSX99bpctWCufV6a67HFK+3OT2bVlOj51eAKaVxVV0dg36
v0fuFGbbT/y8DPEmlMNHaGBjiOxwzp1VE+6nwQV4G+5Fxd7KeCiLs5npZ/JaYvX/
+WEp4TrR68flFDVXw4Yf
=V2Lm
-----END PGP SIGNATURE-----

--hLm5PKjcgVKexwMJ7SQliGjBSCHqdMfe0--
