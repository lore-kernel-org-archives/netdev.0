From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net-next v4 3/9] ipv6: sr: add support for SRH encapsulation
 and injection with lwtunnels
Date: Sun, 6 Nov 2016 15:02:07 +0100
Message-ID: <581F37DF.4060509@uclouvain.be>
References: <1478255388-32213-1-git-send-email-david.lebrun@uclouvain.be> <1478255388-32213-4-git-send-email-david.lebrun@uclouvain.be> <CALx6S35TVxfmB-Rc=0HpSkLP9-FKHLcsHf97Y=ro_Q_-G5P1XA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="6MrN7pUBWcst7iTDWWpOcMD4x1jm5SfJF"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:44578 "EHLO
        smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751732AbcKFOHi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2016 09:07:38 -0500
In-Reply-To: <CALx6S35TVxfmB-Rc=0HpSkLP9-FKHLcsHf97Y=ro_Q_-G5P1XA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--6MrN7pUBWcst7iTDWWpOcMD4x1jm5SfJF
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/04/2016 05:26 PM, Tom Herbert wrote:
>> +
>> +int seg6_output(struct net *net, struct sock *sk, struct sk_buff *skb=
)
>> +{
>> +       struct dst_entry *orig_dst =3D skb_dst(skb);
>> +       struct dst_entry *dst =3D NULL;
>> +       struct seg6_lwt *slwt;
>> +       int err =3D -EINVAL;
>> +
>> +       err =3D seg6_do_srh(skb);
>=20
> Technically we're not allowed by the standard to insert extension
> headers when forwarding, only the source host can place EH in packets.
> There was a _long_ discussion about this in 6man WG and it appears
> that for RFC2460bis the plan is to make this point clear. The
> rationale is that inserting extension headers in the middle of the
> network break PMTUD, IPsec AH, amongst other things.
>=20
> I think people are going to do this anyway (especially for something
> like SR) so I don't think we should abandon this patch. But, we
> probably need a big disclaimer documented that if someone does this
> they may see problems in the network (in other words they should only
> use this if they know what they are doing).
>=20

Agreed that directly inserting an EH breaks a lot of things. Note that
this concerns only seg6_do_srh_inline(). The other function,
seg6_do_srh_encap(), uses an outer IPv6 header to carry the SRH which is
RFC compliant. Also agreed that people are going to use direct insertion
regardless of RFC.

Where do you think the disclaimer should be ? Documentation/ file ?
Perhaps I can create a specific option CONFIG_IPV6_SEG6_INLINE to enable
or disable direct insertion.


>> +
>> +       memcpy(&slwt->tuninfo, tuninfo, tuninfo_len);
>> +
> Thomas pointed out to me that we are just blindly copying the SR
> option from userspace. We really should validate that it is well
> formed and acceptable to send. Minimally, we should check that
> addresses are valid, the TLVs are well formed, and we need to decide
> on rather to allow arbitrary TLVs that are unknown to the kernel. Same
> thing should be true for socket options or other interfaces to program
> SR.
>=20

Yep, I overlooked that part of the patch and this indeed also applies to
the setsockopt() interface. I will respin a patch series with this issue
fixed.

Thanks for the feedback

David


--6MrN7pUBWcst7iTDWWpOcMD4x1jm5SfJF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlgfN+QACgkQjbzn67sZ6ANW2gCfcFYoJioLVzUAmBdhrT+mosfN
SlgAnRYw1a2ahVbrJazzetUtqd3HWJZu
=QMv/
-----END PGP SIGNATURE-----

--6MrN7pUBWcst7iTDWWpOcMD4x1jm5SfJF--
