From: Michael Bellion and Thomas Heinz <nf@hipac.org>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Tue, 12 Aug 2003 16:56:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F390021.5040705@hipac.org>
References: <200307141045.40999.nf@hipac.org>	<1058328537.1797.24.camel@jzny.localdomain>	<3F16A0E5.1080007@hipac.org>	<1059934468.1103.41.camel@jzny.localdomain>	<3F2E5CD6.4030500@hipac.org>	<1060012260.1103.380.camel@jzny.localdomain>	<3F302E04.1090503@hipac.org>	<1060286331.1025.73.camel@jzny.localdomain>	<3F381B3E.6080807@hipac.org> <20030811224050.59bc36fe.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig55A077B958DF8779F8D68BBA"
Cc: hadi@cyberus.ca, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030811224050.59bc36fe.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig55A077B958DF8779F8D68BBA
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi David

You wrote:
> The ipv4 FIB hash tables tackle exactly this problem.  The resulting
> worse cast complexity is O(n_bits_in_prefix_mask).
> 
> The problem you've described is exactly the same as trying to use
> hashing for routing tables.

Yes, that's true for the 1-dimensional case. You refer to the
following algorithm, don't you?

    min_prio := infinity
    match_rule := nil
    for all list_entries e: { // at most w+1 entries where w is the bit
                              // width of the keys
        rule = lookup(hash(e), packet)  // let's assume O(1) here
        if (prio(rule) < min_prio) {
		min_prio = prio(rule)
                 match_rule = rule
        }
    }
    return match_rule

This algorithm has running time O(w).
[In fact it's O(number of different prefix lengths) which is O(w)
  in the worst case.]

But what about the d-dimensional case? If you extend this
approach to handle rules with d prefix based matches you end
up in a running time of:  O(w^d)
                          (assuming w to be the max. bit width)

This is definitely not desirable.


Regards,

+-----------------------+----------------------+
|   Michael Bellion     |     Thomas Heinz     |
| <mbellion@hipac.org>  |  <creatix@hipac.org> |
+-----------------------+----------------------+
|    High Performance Packet Classification    |
|       nf-hipac: http://www.hipac.org/        |
+----------------------------------------------+

--------------enig55A077B958DF8779F8D68BBA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Using GnuPG with Debian - http://enigmail.mozdev.org

iD8DBQE/OQAhtXh2AYIMjggRAgg6AJ9jY3FJa4irGLO40byWJQIU6+/hmQCfd/xv
p0o5BtK8fQlHpIQ5tUnu8Iw=
=Ck7A
-----END PGP SIGNATURE-----

--------------enig55A077B958DF8779F8D68BBA--
