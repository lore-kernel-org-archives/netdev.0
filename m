From: Michael Richardson <mcr@sandelman.ca>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Sat, 17 Nov 2012 17:14:48 -0500
Message-ID: <12918.1353190488@obiwan.sandelman.ca>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com> <3246.1351717319@obiwan.sandelman.ca> <CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com> <87mwyi9h1x.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: tcpdump-workers@lists.tcpdump.org,
	ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from tuna.sandelman.ca ([209.87.252.184]:42599 "EHLO
	tuna.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201Ab2KQWPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 17:15:18 -0500
In-Reply-To: <87mwyi9h1x.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Transfer-Encoding: quoted-printable


Thank you for this reply.

>>>>> "Eric" =3D=3D Eric W Biederman <ebiederm@xmission.com> writes:
    Eric> I don't see any need to add any kernel code to allow checking
    Eric> if vlan tags are stripped.  Vlan headers are stripped on all
    Eric> kernel interfaces today.  Vlan headers have been stripped on
    Eric> all but a handful of software interfaces for 6+ years.  For
    Eric> all kernels if the vlan header is stripped it is reported in
    Eric> the auxdata, upon packet reception.  Careful code should also
    Eric> look for TP_STATUS_VLAN_VALID which allows for distinguishing
    Eric> a striped vlan header of 0 from no vlan header.

I can regularly see vlan tags on raw dumps from the untagged ("eth0")
today, running 3.2 (debian stable):

obiwan-[~] mcr 4848 %sudo tcpdump -i eth0 -n -p -e | grep -i vlan
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
17:05:15.404909 38:60:77:38:e6:47 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x=
8100), length 46: vlan 3800, p 0, ethertype ARP, Request who-has 172.30.42.=
1 tell 172.30.42.11, length 28

So, I'm curious about the statement that vlan tags have been stripped
for some time, because I don't see them stripped today.  My desktop has
an Intel 82579V NIC in it...


    Eric> For old kernels that do not support the new extensions it is
    Eric> possible to generate code that looks at the ethernet header
    Eric> and sees if the ethertype is 0x8100 and then does things with
    Eric> it, but that will only work on a small handful of software
    Eric> only interfaces.

at tcpdump.org, our concern is to release code that works on both new,
and what for kernel.org folks would be considered "ancient" systems,
such as Centos5/RHEL5 machines which are regularly still in production
in the field (sadly...), but often need the latest diagnostics.

What I hear you saying is that our existing code will work on older
kernels, and that once we have new code to use the VLAN tag extensions,
we should simply attempt to load it, and either it loads, or we get an=20
error, and we go back to the code we had before.   That's great news.

The major concern is that if the 802.1q header is gone, although we can
retrieve it somehow (I'm not sure how the AUXDATA is presented on the
MMAP PF_PACKET interface...) we will have to reconstruct it in order to
save it properly to a savefile.  Many entities, including most major
Network Telescopes (http://en.wikipedia.org/wiki/Network_telescope) use
libpcap (and often tcpdump itself) to capture packets on probe points,
and having good performance matters here...=20

=2D-=20
]       He who is tired of Weird Al is tired of life!           |  firewall=
s  [
]   Michael Richardson, Sandelman Software Works, Ottawa, ON    |net archit=
ect[
] mcr@sandelman.ottawa.on.ca http://www.sandelman.ottawa.on.ca/ |device dri=
ver[
   Kyoto Plus: watch the video <http://www.youtube.com/watch?v=3Dkzx1ycLXQS=
E>
	               then sign the petition.=20


--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQCVAwUAUKgMWIqHRg3pndX9AQLzNQQAzN08SM+jnB5HC816EdkKg8taeNNGhNwj
NT1xASQqLaET1JEOKYeWscpIF13/N42pEFhi5ovwQP5Xu8mVAnCRHcSil7FL1iD3
aUWdw0hJSz0XmAlMgk8pkheO3rTcWtRLjyWZrrB/gEwlCVcvPCQDnCDW9JX5689j
dd4LeDrBNrg=
=wnBi
-----END PGP SIGNATURE-----
--=-=-=--
