From: "Michael Richardson" <mcr@xelerance.com>
Subject: Re: v6-in-v4 IPsec and NAT traversal
Date: Sat, 13 Mar 2004 12:24:56 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4831.1079198696@marajade.sandelman.ottawa.on.ca>
References: <Pine.LNX.4.44.0403131137400.22557-100000@netcore.fi>
Cc: netdev@oss.sgi.com, dev@lists.openswan.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: Message from Pekka Savola <pekkas@netcore.fi>
   of "Sat, 13 Mar 2004 11:43:04 +0200." <Pine.LNX.4.44.0403131137400.22557-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----


>>>>> "Pekka" == Pekka Savola <pekkas@netcore.fi> writes:
    Pekka> I'm interested whether Linux IPsec implementations support:

    Pekka>  1) IPv6 payload inside IPv4 IPsec tunnel/transport?

    Pekka>  That is, when the intermediate network doesn't support IPv6,
    Pekka> you could do IPv6, secured, without first encapsulating in
    Pekka> IPv6-over-IPv4 tunnel and then running IPv6 IPsec.

  I don't know if 26sec can do it at the bottom layer - I think not.
  I can tell you that neither racoon nor pluto can negotiate a mixed
mode SA. Both are pretty close - but at present no real testing is done
on that.

    Pekka>  2) NAT-traversal? (There are at least some patches in
    Pekka> OpenSWAN, etc. for this).  This could be very handy combined
    Pekka> with the above.

  Both 26sec and KLIPS have support for NAT-Traversal for IPv4, but
both requires support from the UDP - this is in 2.6, 2.4 backport, and 
showing up in many distros. The patch is 140 lines.
  Pluto will detect the kernel support for NAT-Traversal and use it
if it exists. 
  I don't know about racoon.

    Pekka> [[ 3) Some feasible key management method, such as
    Pekka> certificates.  I think this exists, and doesn't require
    Pekka> support in the kernel. ]]

  Racoon has poor pkix-self-signed certificate support.
  Pluto has pkix, raw RSA, RSA-from-DNS. The latest X.509 patches from
Andreas (not yet integrated) include OCSP (RFC2560). 

    Pekka> I'm considering how viable this kind of NAT -traversal
    Pekka> supporting v6-in-v4 IPsec would be as an IPv6
    Pekka> tunneling/transition mechanism.

  Well, I was rather hoping that NAT-traversal for IPsec would have been
done as:
     IPv4/ESP/IPv6/Teredo/UDP/IPv4.

    Pekka> What's the status (implementations, planned or future) of
    Pekka> these features?

  http://www.openswan.org/development/roadmap.php

- --
]       ON HUMILITY: to err is human. To moo, bovine.           |  firewalls  [
]   Michael Richardson,    Xelerance Corporation, Ottawa, ON    |net architect[
] mcr@xelerance.com      http://www.sandelman.ottawa.on.ca/mcr/ |device driver[
] panic("Just another Debian GNU/Linux using, kernel hacking, security guy"); [

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Finger me for keys

iQCVAwUBQFNDp4qHRg3pndX9AQHmGwP/TsrZQ4etRT4SBWVJtV+FZJ6iqeMytexi
aqfCcAINlQV5/8wWo45/cwdOuJ/t6dHxffZGYFnbXeZzZyzxGqgraB/UscAX9zcN
rfDKSgs3ShwR8T5VKnKYeMjqELifGDJKOQFtaOvgcXG0yzQdVLG/XzBhgDUSmmnA
32OtcTr2tes=
=J4Bs
-----END PGP SIGNATURE-----
