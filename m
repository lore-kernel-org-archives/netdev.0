From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH 1/9] batman-adv: add UNICAST_4ADDR packet
	type
Date: Sun, 04 Nov 2012 11:29:29 +0100
Message-ID: <12758662.vFhVQet4vg@sven-laptop.home.narfation.org>
References: <1351968514-12357-1-git-send-email-ordex@autistici.org>
 <1351968514-12357-2-git-send-email-ordex@autistici.org>
 <20121103.152226.244759041688205348.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart6149278.16tMfUHuyf";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20121103.152226.244759041688205348.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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


--nextPart6149278.16tMfUHuyf
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Saturday 03 November 2012 15:22:26 David Miller wrote:
[...]
> Your packet layouts are very poorly designed and I want you to stop
> and think seriously about things before extending things further.

You are right about the packet design/layout. But I also have some problems 
with the following statement. Maybe you can help me to resolve it.

> All of this __packed stuff is a serious problem.
> 
> It means that on RISC system, fields such as your 32-bit sequence
> number, will be read and written using byte loads and stores.
> 
> This is terrible.
> 
> Instead, design the structures so that they are full filled out to
> at least 4 byte boundaries, so that they and the contents after
> them, are 4 byte aligned too.
> 
> Then you won't need to mark all of your packet header structs
> with __packed, and therefore the compiler can use full 32-bit
> loads and stores to access 32-bit fields.

Ok, lets assume batman-adv has everything 4 byte aligned and we are running on 
a machine without unaligned r/w access. The machine may issues bus errors and 
so on.

Now also assume following really unusual situation: We get our data from a 
ethernet driver and the skb stores the ethernet header. The start of the 
ethernet header is perfectly aligned (4 or even 16 byte boundary aligned). The 
the header is 14/18 byte long (6 byte src, 6 byte dst, 2 byte ethertype and 
maybe 4 byte vlan). Now the payload starts only on a 2 byte boundary -> it is 
never 4 byte boundary aligned. A 32 bit read now causes different variations 
of problems (reminder: bus error).

This brings me to the question: Why should the "32 bit align everything 
relative to the start of the struct" approach help to resolve the situation 
for the access of 32 bit data structure members? May I am missing some 
information?

Kind regards,
	Sven
--nextPart6149278.16tMfUHuyf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQlkOJAAoJEF2HCgfBJntGBuIP/06JXx/X1xT6EQZHPPHSQAjI
/LUZTIN33EW+PxyEbcTMmiKeA+KfZnvHm1jeiVA+EFaw4yYxS4Vh6EOreR0F9sUq
SP/ErNTJQqPlmolfaCjHhBqbyb6YZ5rQpCvFqWZoqL8IPzywkNikGTdXr7XZifWN
a+k0eZJwS2kZkhYhZFSQtcDxYO3k1SFQwg4joGcpb6Cr5eeOytQ3r1/Mi3pfzNfl
+vWSO6qxBE+dmqUGGg7K0uvHcfl90qlRnx4i6MBmSAwB0NMmPB7LMJ4Phktj3YYo
UXgi9wMTMdmyBFYuclmKu1wCaBgr+jetwKIYUHxKSvOZVOVbQHSQnDUOeNqDJ3d4
9Ck7JRAZ3/fImye3gFYw33NWpvylp5BK7YZJ4UDAxCz8Ym87Tg8CcaNRE7RrA0Ef
xzC+3exEdsbzbniGFB3NjDhCQER1XB1mToInSogqMn6CJyuWMkqNwJ+QLnLKRSiT
p6An00SuR/YwO1qg6C9fK/6lkXmyusIymKLE2sVi1eQaj2a5Ohh7j6CmVx3CM7nP
9yQZRiEqQRMpVOMvlOIZ0qPVA0pLX1jyQJIFMiyqna2CIudWBoh/IbOoU3o9fCda
Nj7FAcn7jrzXpVDyA8gfRRSHtfpJ2+VcBorY8FLr/lPeb9XOKmfLJ2xGmwi6DwvD
MxySPcDhaAN4WGuDb/CT
=uZal
-----END PGP SIGNATURE-----

--nextPart6149278.16tMfUHuyf--
