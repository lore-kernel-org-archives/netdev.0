From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 08/10] net/smc: introduce a delay
Date: Wed, 20 Sep 2017 16:37:04 +0200
Message-ID: <a8d7b051-8f43-3e21-714f-50d7faa53e0e@linux.vnet.ibm.com>
References: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
 <20170920115813.63745-9-ubraun@linux.vnet.ibm.com>
 <20170920140315.GR5788@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="gkd84svHUA67ToIcEcsqtjfc0Dii1QHOK"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:53344 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751507AbdITOhS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:37:18 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8KEYYNX041727
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 10:37:18 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d3su8sxng-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 10:37:17 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 20 Sep 2017 15:37:15 +0100
In-Reply-To: <20170920140315.GR5788@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--gkd84svHUA67ToIcEcsqtjfc0Dii1QHOK
Content-Type: multipart/mixed; boundary="8OdOVkRTXPcxCKrF39VBeoAWtMhHeXovL";
 protected-headers="v1"
From: Ursula Braun <ubraun@linux.vnet.ibm.com>
To: Leon Romanovsky <leon@kernel.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
 linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
 heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com
Message-ID: <a8d7b051-8f43-3e21-714f-50d7faa53e0e@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 08/10] net/smc: introduce a delay
References: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
 <20170920115813.63745-9-ubraun@linux.vnet.ibm.com>
 <20170920140315.GR5788@mtr-leonro.local>
In-Reply-To: <20170920140315.GR5788@mtr-leonro.local>

--8OdOVkRTXPcxCKrF39VBeoAWtMhHeXovL
Content-Type: multipart/mixed;
 boundary="------------1E0C141913ED17CAC1DF69B0"
Content-Language: en-US

This is a multi-part message in MIME format.
--------------1E0C141913ED17CAC1DF69B0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable



On 09/20/2017 04:03 PM, Leon Romanovsky wrote:
> On Wed, Sep 20, 2017 at 01:58:11PM +0200, Ursula Braun wrote:
>> The number of outstanding work requests is limited. If all work
>> requests are in use, tx processing is postponed to another scheduling
>> of the tx worker. Switch to a delayed worker to have a gap for tx
>> completion queue events before the next retry.
>>
>=20
> How will delay prevent and protect the resource exhausting?
>=20
> Thanks
>=20

SMC runs with a fixed number of in-flight work requests per QP (constant
SMC_WR_BUF_CNT) to prevent resource exhausting. If all work requests are
currently in use, sending of another work request has to wait till some
outstanding work request is confirmed via send completion queue. If sendi=
ng
is done in a context which is not allowed to wait, the tx_worker is
scheduled instead.
With this patch a small delay is added to avoid too many unsuccessful sen=
d
retries due to a still ongoing "all work requests in use" condition.

--------------1E0C141913ED17CAC1DF69B0
Content-Type: application/pgp-keys;
 name="0xC5ED6645.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="0xC5ED6645.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2.0.14 (GNU/Linux)

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3D=3D
=3D+Xkm
-----END PGP PUBLIC KEY BLOCK-----

--------------1E0C141913ED17CAC1DF69B0--

--8OdOVkRTXPcxCKrF39VBeoAWtMhHeXovL--

--gkd84svHUA67ToIcEcsqtjfc0Dii1QHOK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iQIcBAEBAgAGBQJZwn0YAAoJEMy9qjTF7WZF1/kQAIn2mhwNu4suFyuHuK4GEcmp
W9CR4XAcxcX25lG9lH6Pf4rRFEyCvNQ7ZRNY7+dU2HL45c61i4pEp+54Z3bJ3U9d
/3drx4/8XLTIPHRD/P12etfXkB7YZAcJZJMukmyVP+vDSu9aZoA/jPiHANftAppM
4OBL36U7yyMvrPykYc4nJ+w2I1jxtq4ICHg6YxuQj8ZYH5zbf4u4USjWMzNWvta3
RuKomtNpHQcRbS/1oen70L6X8L7kD2680eAxSxs8x6jpwZVFtMqX2S/W+E56JNwu
+K6xUqGy0OOxNF434uGWw3j4Z89xqtwUOOupjAX6EkAvZY9npRGHiQlGIIydcQCg
y2zMhOd1GwAnjcjo/96mrbIK0Q1kNrO0LFCUqg6mE0MEhqMfX40/vz/OVIWCsVOR
Ipd+TKAEUL1YrUaWdUlS8oonWyaqXzC1atGysk48LKQUEC11gQ656uqIvb0EJE8A
Z591wONnC7UttiTViz5UlQF0wnmaSgHDt3BEJi0cxTp3kiM7fv1mDJdfwZ034EZZ
JURTL9bVqbgsWmL+VFXadUsGlNs+8fWCnau/swZi+a4DE+SG2kECQZuKDSUq/0sW
Ow2vis7J2yGBnggtPBw97KPHtFWQtkvaQJEkk2c9cc/m956oYZ5Xk0hGnkQpCX8O
5twjx7SQ50oUYfGZZTE1
=XolZ
-----END PGP SIGNATURE-----

--gkd84svHUA67ToIcEcsqtjfc0Dii1QHOK--
