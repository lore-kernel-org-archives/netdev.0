From: Michael Bellion and Thomas Heinz <nf@hipac.org>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Tue, 12 Aug 2003 17:39:15 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F390A23.3050409@hipac.org>
References: <200307141045.40999.nf@hipac.org> <1058328537.1797.24.camel@jzny.localdomain> <3F16A0E5.1080007@hipac.org> <1059934468.1103.41.camel@jzny.localdomain> <3F2E5CD6.4030500@hipac.org> <1060012260.1103.380.camel@jzny.localdomain> <3F302E04.1090503@hipac.org> <1060286331.1025.73.camel@jzny.localdomain> <3F381B3E.6080807@hipac.org> <20030811224050.59bc36fe.davem@redhat.com> <20030812142913.GB18802@mail.jlokier.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4CDC2936C056ECD43B226B35"
Cc: "David S. Miller" <davem@redhat.com>, hadi@cyberus.ca,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamie Lokier <jamie@shareable.org>
In-Reply-To: <20030812142913.GB18802@mail.jlokier.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4CDC2936C056ECD43B226B35
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jamie

You wrote:
> You can do it in O(log(n_bits_in_prefix_mask)).
> 
> This is achieved using binary search on the prefix lengths which
> appear in the table.  (So if only a few prefix lengths are used, the
> tree is small).
> 
> [example snipped]

That's true for the one dimensional PCP (with prefix rules) if
the following condition holds:
for all rules r1, r2: (prefix(r1) > prefix(r2)) &&
                       (r1 & prefix(r2) == r2 & prefix(r2))
                    => prio(r1) < prio(r2)
                       [smallest prio wins]

It's quite reasonable to assume that this condition holds
for the one dimensional case since there would be never
matching rules otherwise.

> This generalises to multiple dimensions e.g. for doing multiple
> prefixes on source+target + different combinations of other bits such
> as protocol, TOS etc. - i.e. arbitrary bit-subset classifiers.  The
> basic principle and the algorithm are the same.

Hm, how do you want to solve the d-dimensional PCP by
doing binary search for each dimension? Remember that
PCP is not related to longest prefix matching. Instead
priorities are used.

Maybe you should describe in little more detail what you mean
by "This generalises to multiple dimensions ...".


Regards,

+-----------------------+----------------------+
|   Michael Bellion     |     Thomas Heinz     |
| <mbellion@hipac.org>  |  <creatix@hipac.org> |
+-----------------------+----------------------+
|    High Performance Packet Classification    |
|       nf-hipac: http://www.hipac.org/        |
+----------------------------------------------+

--------------enig4CDC2936C056ECD43B226B35
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Using GnuPG with Debian - http://enigmail.mozdev.org

iD8DBQE/OQojtXh2AYIMjggRAkH8AJ40A+oT0az3er5KDD/QrouBl1SKiwCfTXf/
MXdcQGU7cSUwjNssBVvu4Lk=
=JZK7
-----END PGP SIGNATURE-----

--------------enig4CDC2936C056ECD43B226B35--
