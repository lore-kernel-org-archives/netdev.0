From: Michael Richardson <mcr@sandelman.ca>
Subject: Re: [tcpdump-workers] [PATCH net 1/2] net: dev_queue_xmit_nit: fix skb->vlan_tci field value
Date: Thu, 10 Jan 2013 20:47:49 -0500
Message-ID: <32117.1357868869@sandelman.ca>
References: <CAOUgPvRGQ4XQ-HCFzwKi5rFFfC1fJcicH8DxH0pUjAvgxfi7cw@mail.gmail.com> <CAOxq_8MXCvGpq4Q0UfxSbWMDNTusrK710fQ11qgfXKWS+zpoZQ@mail.gmail.com> <1357712850.27446.28.camel@edumazet-glaptop> <CAOxq_8P=yOYGhhJ2_YJT3ya32k7UNjX6d6Qpz+oVfD4d56sJfQ@mail.gmail.com> <CAOxq_8P4PLKXn9FOAWyq4zYH5+Yt7DT1mrU2OSQujGCOjBJZYg@mail.gmail.com>  <1357761063.27446.60.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Ani Sinha <ani@aristanetworks.com>, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org, edumazet <edumazet@google.com>,
	tcpdump-workers@lists.tcpdump.org, dborkman <dborkman@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tuna.sandelman.ca ([209.87.252.184]:43865 "EHLO
	tuna.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753594Ab3AKB7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 20:59:11 -0500
In-Reply-To: <1357761063.27446.60.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Transfer-Encoding: quoted-printable


>>>>> "Eric" =3D=3D Eric Dumazet <eric.dumazet@gmail.com> writes:
    Eric> On Wed, 2013-01-09 at 11:27 -0800, Ani Sinha wrote:

    >> This is wrong. Accelerated or not, the kernel code was organized to
    >> have the tags in the packet aux data. So I think this is how user la=
nd
    >> should be coded as well.

    Eric> You have your opinion, thats good.

    Eric> My opinion as a kernel developer is that the network tap is here =
to have
    Eric> a copy of the exact frame given to the _device_.

Good: as someone who spends lots of time with tcpdump doing both network
and protocol diagnostics, it's really important to see exactly there.
If that means turning off some hardware offload in order to get the
intact 1p header, then that may be fine for many situations.
(At 10G, on a live router... well...)

The problem is that now we need to know, on a per device basis (based
upon the current configuration) if the VLAN tag was removed by the
hardware or not.  It's not enough to try with vlan tag and not.

    Eric> If you want other taps, and catch frames before/after various net=
filter
    Eric> hooks, segmentations, vlan accel, tunnels, or before GRO layer, t=
hats a
    Eric> totally different request.

Yes!!!! We need all of these tap points too...=20

=2D-=20
]               Never tell me the odds!                 | ipv6 mesh network=
s [=20
]   Michael Richardson, Sandelman Software Works        | network architect=
  [=20
]     mcr@sandelman.ca  http://www.sandelman.ca/        |   ruby on rails  =
  [=20
=09



--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQCVAwUAUO9vRYqHRg3pndX9AQKf1QP/Rx/iOYtNIeldL9FvBJmqBglXuWHzoNI+
6gAGgp9UZrGbkrMt7VWDfTE9dRxXq9XCL//UDqZ4JhKlh/5JttObvr+mQek//toF
7UziOX99TnBqPowoCdydkuRLeEkvBPcqA1+2lDaDRwlsd46F7xU76UbGFlOPEqT+
lYugbzlez1g=
=hrOy
-----END PGP SIGNATURE-----
--=-=-=--
