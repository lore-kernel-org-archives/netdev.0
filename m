From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH net] net: batman-adv: Fix possible
	memleaks when fail to register_netdevice
Date: Wed, 26 Apr 2017 09:16:54 +0200
Message-ID: <2857108.moq831zFsU@bentobox>
References: <1493121800-28066-1-git-send-email-gfree.wind@foxmail.com>
 <3994535.Z9kqCnttI2@bentobox> <002101d2be58$8bcaaa00$a35ffe00$@foxmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart5133299.AJ2vO75GQ0";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, a@unstable.cc, 'Gao Feng' <fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org>,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Gao Feng <gfree.wind-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <002101d2be58$8bcaaa00$a35ffe00$@foxmail.com>
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

--nextPart5133299.AJ2vO75GQ0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Mittwoch, 26. April 2017 14:44:24 CEST Gao Feng wrote:
[...]
> I get it now, thanks.
[...]
> BTW, I think although the batadv_softif_create is legacy, we should fix it
> when it still exists :)

I didn't meant that we should not fix it. I just said that it looks to me like 
the fix should look different to ensure that it actually fixes the sysfs and 
rtnl link implementation for the batadv interface creation. Right now the 
ndo_uninit (when it would be set by batadv) is called in the netdev core 
functions when an error happens during the registration. This is not the case 
for the destructor. Your patch would not change it. It therefore looks like 
you simply have to move the current destructor (without the free_netdev) to 
ndo_uninit and change the destructor to free_netdev.

The batadv ops doesn't have a newlink function. It will therefore use the 
register_netdevice code path which calls free_netdev on failures. The extra 
cleanup you've added in
 https://www.mail-archive.com/netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg165253.html can 
therefore not work for batman-adv. Actually, it is not touching anything 
batman-adv related. The suggestion to change the register_netdevice -> 
free_netdev part in rtnl_newlink was new in the reply to the batadv 
discussion. It is therefore still an open discussion how it is correctly 
fixed.

Kind regards,
	Sven


--nextPart5133299.AJ2vO75GQ0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAlkASWYACgkQXYcKB8Em
e0aqig/9GRlQg9D7UPC58+bcZwC8eAw7TcEV39jOIVUjRyug6UGrCl6msR4/ZXMO
q/aAR24DzEF/JSr+uWv1+u3bEtJHRYbfRwNXSaZLJOBDZ02ryObUhvKHkKdjPV/Y
dqieWd0dVbWFK6RcX4pI/ierOYaX8raF7teIw8X1wcJvTbguzFBdmQLtO3F877NZ
4K0nSG6QRwTPdU8fvAOlHnLZJ1DV/FQLZ9Co+jzqNKr5Zk57lOwaPFIOmF2gF23h
g59tWeG6TGRn1XGncYE+cegT2eGg7KPytEUq1qRRLAEg9LljFgdRgcgXrOj1jsPw
yB5q8Z3V3xvJ2DAHo7OdUR+60LiJajukhXgOzLHSRjDEzsBuW649s9ok7AnCMLje
ixyvHZybGMkOlflsvD/4AvX7pSYncRzNyfX6k529220MrR4tcR909n5JcGABOUAJ
HjalPB375zeQaAQjAWGFuzv0o2t67jEnkWyD+3ce9i2EuU6/ixtiZ0gV0mzO2uog
2PKX4YEIEhck62EUL0LD8QrY0PxXcw+9EVXQS+PTF23OpsFjBNAU3tAr0hNprkHG
HSvv6XEQ7SmDO2UBIuCrooltBcPFSLRev1YW5gcTHGl/kwifs8yeke7QI7S2ephY
ddqewlUr8v/ur1eKWp7/C+K7rFW/4u7B0YSVeu1kbzx3JjBpuKI=
=AkR7
-----END PGP SIGNATURE-----

--nextPart5133299.AJ2vO75GQ0--
