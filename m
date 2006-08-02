From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: [RFC] Mobile IPv6 introduction
Date: Wed, 2 Aug 2006 11:47:56 +0100
Message-ID: <20060802104756.GN8334@innerghost.net>
References: <44CB2914.9010803@linux-ipv6.org> <20060729141244.GJ8334@innerghost.net> <44D01AEE.3030606@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Fl9V9vFrQUs+59QW"
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:41697 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S1750743AbWHBKsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 06:48:00 -0400
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <44D01AEE.3030606@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Fl9V9vFrQUs+59QW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

   Thanks for the reply, however:

On Wed, Aug 02, 2006 at 12:24:30PM +0900, Masahide NAKAMURA wrote:
> Our patch is similar as you said.  Our design is that kernel does nothing
> as possible about validation which can be done by user-space.
> As you mentioned ICMPv6 error is hard to be sent by user-space because it carries
> original packet causing error. MIPv6 RFC says when mobility header length is too short
> ICMPv6 error (parameter problem) is sent. We also discussed about design like your choice.
> but we have not taken it because ICMPv6 sending mechanism is already in kernel
> then it is reasonable to use it. We MIPL developers concluded that kernel should
> know mobility header types and their minimum length at least. I guess when we would
> support NEMO and FMIPv6, we just add their defines at that time.
> (Actually, their implementations based on MIPL2 exists.)
> If somebody would feel that such defines should be removed from kernel we have another
> idea to make new socket interface like ICMP filter to store mobility header type and its
> minimum length to kernel by user-space.

   Although the ICMP-filter approach would be better, it is not flexible
 enough to handle this situation. We must also send ICMPv6 Parameter
 Problems when ip6mh_proto isn't IPPROTO_NONE. I don't think it is too
 much of a burthen to handle ICMPv6 in the control daemon because you
 should already do so to react to ICMPv6 error messages from peers
 concerning MIPv6 signalling. I'm strongly against doing these checks in
 the kernel for the simple reason that it is not easily extendable.  You
 wouldn't be able to deploy a new daemon version over an existing kernel
 with these changes if it supported a new control protocol with new
 messages. I think we should follow a different path here and i propose
 either have a hdrinc=1 mode (for reception only) for protocol raw
 sockets, possibly adding with control on reception which specifies the
 offset of the UPL header; or have a control message to obtain the
 network headers. For instance:

      put_cmsg(msg, SOL_IPV6, ..., (skb->h.raw - skb->nh.raw),
               skb->nh.raw);

   Hugo

--Fl9V9vFrQUs+59QW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFE0ILc7asb/itUNKwRAsZzAJ9DJZM/BJDYiRGCvTv5MLyHlhvmpQCg3hsJ
P7J44ioAawnHpZZ5seLUJUU=
=ODRN
-----END PGP SIGNATURE-----

--Fl9V9vFrQUs+59QW--
