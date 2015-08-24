From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH v2 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Mon, 24 Aug 2015 09:33:48 +0200
Message-ID: <20150824073348.GL19683@calimero.vinschen.de>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <1440151756-18165-1-git-send-email-vinschen@redhat.com>
 <20150821193926.GA16437@electric-eye.fr.zoreil.com>
 <20150821220756.GI19683@calimero.vinschen.de>
 <20150821235940.GA20313@electric-eye.fr.zoreil.com>
 <20150822083916.GA17408@calimero.vinschen.de>
 <20150822112334.GB24519@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="7uYPyRQQ5N0D02nI"
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>,
	nic_swsd <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:39081 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbbHXHdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 03:33:51 -0400
Content-Disposition: inline
In-Reply-To: <20150822112334.GB24519@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--7uYPyRQQ5N0D02nI
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 22 13:23, Francois Romieu wrote:
> Corinna Vinschen <vinschen@redhat.com> :
> [...]
> > That won't happen with the current patch because only
> > rtl8169_reset_counters would print a log message, it's only called from
> > open, and open occurs rather seldom.  Atop of that the code only tries
> > to reset counters on HW supporting it, and only if resetting on the HW
> > fails, there will be a log message at all.  There's no reasonable chance
> > that failing to reset the counters will lead to log flooding.
>=20
> Thanks for reformulating it. We are in violent agreement here.
>=20
> [...]
> > I'm not trying to avoid work, I'm trying to understand.
> >=20
> > As far as I see it failing to reset the counters has no impact on the
> > viability of the code.  It's still working with offsets and if the
> > offset is 0 or non-0, the user space won't see the difference in the
> > values returned by @get_stats64.  Successful resetting the counters is
> > just a bonus.
>=20
> Sorry, my english was really bad:
>=20
> the code should propagate failure when rtl8169_reset_counters and
> rtl8169_update_counters *simultaneously* fail.

Uhm... sorry, but that still doesn't answer the question.  As you can
see in my patch, the initalization at open time is already encapsulated
in a function rtl8169_init_counter_offsets.=20

Assuming rtl8169_init_counter_offsets returns -1 if both functions,
rtl8169_reset_counters and rtl8169_update_counters fail.

Then... what?

Not being able to reset or update the counters is still not at all fatal
for the operation of the NIC as a whole and rtl_open in particular:

  rtl_open()
  {
    [...]

    /* This is non-fatal. */
    if (!rtl8169_init_counter_offsets ()) {

	  /* What to do here??? */

    }

    [...]
  }


Corinna

--7uYPyRQQ5N0D02nI
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV2sjcAAoJEPU2Bp2uRE+g6bAP+wcrB3YNnpdQJtHUs471jGFM
f/XlJACMHGLtfWG7zxd5zAITaewbW6D4ggFBwe1yzkpthgFn/tJimR5ruAORDP8P
znfxVJcr9g3Ykz8R5U5HH6udsUgky6SdlM0mx/Drti1poYljTlpvXS7QpSQQM6Rh
CefPeNkPq/PCBOPtHYWFWc1C9HyXjFfHNAvc2dJJuFjnpSOxBFmrjlombGAjfobI
a7P3Y/z5GHNJC4QhepCuIM/W5V4OVZof5zFoVMxS2qTKWOn1BpmO0DDf0aZbSCGG
RGCURQ8RAZXNB7+kshHqhv/Owr4oAHc16/B50ijfrf5N4Qnxbw6iQAPp6EPlUhkZ
ssLMPDGZ3GyRyKZYNd+QYyZKwJvwhM7A3VAfTYR7csbhRueFHGNhrbQyvoGbevib
8IvI8Q58RikDP8wnGBJMJ/AUCRC/TtCJEgN3DAPLOxyuXNz+Xqe35efwtrye5b+z
y3HWZacWHUNuWabqL3KoqjhBj8SmcS7gq+nuNTzFscw4YSBI/sloQLQwwRrNasos
Uxe/ryhDzkcAnzJCDxZQ2vUaXtJNIp3PHdHhLrN/oLEaGPhuVy9HvhiMViWEfDm4
Uokug5ZYBQ2AUXrnGEJrHiey44gBRRavdZ6uTtNNBAdkwMIEfx7bd0FBZPdmVT2M
1+H69QHC/Ybw3eam1luN
=TswV
-----END PGP SIGNATURE-----

--7uYPyRQQ5N0D02nI--
