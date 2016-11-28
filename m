From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [net PATCH 0/2] Don't use lco_csum to compute IPv4 checksum
Date: Tue, 29 Nov 2016 10:43:04 +1100
Message-ID: <20161129104253.00ada847@canb.auug.org.au>
References: <20161128153927.15466.99193.stgit@ahduyck-blue-test.jf.intel.com>
        <1480371962.2402.36.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        davem@davemloft.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:47549 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754432AbcK1XnG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 18:43:06 -0500
In-Reply-To: <1480371962.2402.36.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

On Mon, 28 Nov 2016 14:26:02 -0800 Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
>
> On Mon, 2016-11-28 at 10:42 -0500, Alexander Duyck wrote:
> > When I implemented the GSO partial support in the Intel drivers I was
> > using
> > lco_csum to compute the checksum that we needed to plug into the IPv4
> > checksum field in order to cancel out the data that was not a part of t=
he
> > IPv4 header.=C2=A0 However this didn't take into account that the trans=
port
> > offset might be pointing to the inner transport header.
> >=20
> > Instead of using lco_csum I have just coded around it so that we can use
> > the outer IP header plus the IP header length to determine where we need
> > to
> > start our checksum and then just call csum_partial ourselves.
> >=20
> > This should fix the SIT issue reported on igb interfaces as well as
> > simliar
> > issues that would pop up on other Intel NICs.
> >=20
> > ---
> >=20
> > Alexander Duyck (2):
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 igb/igbvf: Don't use lco_csum to compute=
 IPv4 checksum
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ixgbe/ixgbevf: Don't use lco_csum to com=
pute IPv4 checksum =20
>=20
> Stephen, I have applied Alex's patches to my net-queue tree. =C2=A0Can you
> confirm they resolve the bug seen?

Its a bit tricky because the origin problem only happens on my
production server (ozlabs.org), but I will see if I can manage to just
remove and reload the driver ...  though, the server is running a 4.7.8
kernel and I am wondering how well these patches will apply?

--=20
Cheers,
Stephen Rothwell
