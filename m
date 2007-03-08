From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Thu, 08 Mar 2007 15:39:07 +0100
Message-ID: <1173364747.14001.7.camel@johannes.berg>
References: <1173144447.15891.93.camel@johannes.berg>
	 <20070306171316.GA19669@bougret.hpl.hp.com>
	 <200703061943.07350.mb@bu3sch.de>
	 <20070307020310.GA20466@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-IXwO8PUpgVaVLp+Ovdez"
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070307020310.GA20466-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-IXwO8PUpgVaVLp+Ovdez
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-03-06 at 18:03 -0800, Jean Tourrilhes wrote:

> 	Ok, please check the patch attached. I don't have a box to
> test that on, and on my 32 bit kernel it is not even compiled, but I
> believe I got everything all right.

Don't I wish it was that easy... Granted, that does seem to fix the
issue with iw_point but that's not the only thing that's broken. Here's
the next thing, I think this only happens after applying that patch,
without it probably just craps out earlier. Same thing happens with
iwevent (and maybe other things too.)

Enabling debugging in wireless tools yields (on my 64-bit kernel with
32-bit userland):
# LD_LIBRARY_PATH=3D.  ./iwlist wlan0 scan
Scan result 4096
[00:18:8B:15:50:8A:35:E0:00:01:00:C0:02:E1:B8:0E:C0:00:00:00:50:8A:35:F0:00=
:19:8B:1B:50:8A:35:E0:00:09:00:01:50:8A:35:F0:47:6F:6C:6F:73:4E:65:74:7A:00=
:18:8B:01:50:8A:35:E0:49:45:45:45:20:38:30:32:2E:31:31:62:67:00:35:F0:00:0C=
:8B:07:50:8A:35:E0:00:00:00:03:00:10:8B:05:50:8A:35:E0:00:00:00:07:00:00:00=
:32:00:10:8B:2B:50:8A:35:E0:00:00:08:00:67:00:35:F0:00:70:8B:21:50:8A:35:E0=
:00:0F:42:40:00:00:00:32:00:1E:84:80:00:00:00:32:00:53:EC:60:00:00:00:32:00=
:5B:8D:80:00:00:00:32:00:89:54:40:00:00:00:32:00:A7:D8:C0:00:00:00:<lots mo=
re zeroes>
wlan0     Scan completed :=20
DBG - stream->current =3D 0x10019008, stream->value =3D (nil), stream->end =
=3D 0x1001a008
DBG - iwe->cmd =3D 0x8B15, iwe->len =3D 24

                         ^^^^^^^^^^^^^ that's already bogus


DBG - event_type =3D 6, event_len =3D 16, pointer =3D 0x1001900c
          Cell 01 - Address: 35:E0:00:01:00:C0=20
DBG - stream->current =3D 0x10019020, stream->value =3D (nil), stream->end =
=3D 0x1001a008
DBG - iwe->cmd =3D 0x8B1B, iwe->len =3D 25
DBG - event_type =3D 8, event_len =3D 4, pointer =3D 0x10019024=20
DBG - extra_len =3D 17, token_len =3D 20618, token =3D 20618, max =3D 33, m=
in =3D 0
                    ESSID:"" [224]=20
DBG - stream->current =3D 0x10019039, stream->value =3D (nil), stream->end =
=3D 0x1001a008
DBG - iwe->cmd =3D 0x8B01, iwe->len =3D 24
DBG - event_type =3D 2, event_len =3D 16, pointer =3D 0x1001903d
                    Protocol:P=EF=BF=BD5=EF=BF=BDIEEE 802.11b=20
DBG - stream->current =3D 0x10019051, stream->value =3D (nil), stream->end =
=3D 0x1001a008
DBG - iwe->cmd =3D 0x8B07, iwe->len =3D 12=20
DBG - event_type =3D 4, event_len =3D 4, pointer =3D 0x10019055
Segmentation fault

Ooops.

Whereas on a 32-bit machine in the same environment it is as it should
be:

Scan result 264
[00:14:8B:15:00:01:00:C0:02:E1:B8:0E:C0:02:5A:F4:9F:CF:18:C0:00:11:8B:1B:00=
:09:00:01:47:6F:6C:6F:73:4E:65:74:7A:00:14:8B:01:49:45:45:45:20:38:30:32:2E=
:31:31:62:67:00:18:C0:00:08:8B:07:00:00:00:03:00:0C:8B:05:00:00:00:07:00:00=
:00:32:00:08:8B:2B:00:00:08:00:00:6C:8B:21:00:0F:42:40:00:00:08:00:00:1E:84=
:80:00:00:08:00:00:53:EC:60:00:00:08:00:00:5B:8D:80:00:00:08:00:00:89:54:40=
:00:00:08:00:00:A7:D8:C0:00:00:08:00:00:B7:1B:00:00:00:08:00:01:12:A8:80:00=
:00:08:00:01:4F:B1:80:00:00:08:00:01:6E:36:00:00:00:08:00:02:25:51:00:00:00=
:08:00:02:DC:6C:00:00:00:08:00:03:37:F9:80:00:00:08:00:00:08:8C:01:64:00:00=
:47:00:20:8C:05:00:18:00:00:DD:16:00:50:F2:01:01:00:00:50:F2:02:01:00:00:50=
:F2:02:01:00:00:50:F2:02:00:1F:8C:02:00:17:00:00:20:4C:61:73:74:20:62:65:61=
:63:6F:6E:3A:20:32:32:30:6D:73:20:61:67:6F]
eth2      Scan completed :=20
DBG - stream->current =3D 0x10019008, stream->value =3D (nil), stream->end =
=3D 0x10019110
DBG - iwe->cmd =3D 0x8B15, iwe->len =3D 20=20

                         ^^^^^^^^^^^^^ look, 4 bytes less. I wonder why tha=
t is!


DBG - event_type =3D 6, event_len =3D 16, pointer =3D 0x1001900c
          Cell 01 - Address: 00:C0:02:E1:B8:0E=20
DBG - stream->current =3D 0x1001901c, stream->value =3D (nil), stream->end =
=3D 0x10019110
[and lots more skipped for clarity]


So there. Do you want to know why too?

Let's look at a debug info dump from my 64-bit kernel:

 <1><96de>: Abbrev Number: 33 (DW_TAG_structure_type)
  <96df>     DW_AT_sibling     : <9717>
  <96e3>     DW_AT_name        : (indirect string, offset: 0x4278): iw_even=
t
  <96e7>     DW_AT_byte_size   : 24
  <96e8>     DW_AT_decl_file   : 225
  <96e9>     DW_AT_decl_line   : 1064
 <2><96eb>: Abbrev Number: 23 (DW_TAG_member)
  <96ec>     DW_AT_name        : len
  <96f0>     DW_AT_decl_file   : 225
  <96f1>     DW_AT_decl_line   : 1065
  <96f3>     DW_AT_type        : <ed>
  <96f7>     DW_AT_data_member_location: 2 byte block: 23 0     (DW_OP_plus=
_uconst: 0)
 <2><96fa>: Abbrev Number: 23 (DW_TAG_member)
  <96fb>     DW_AT_name        : cmd
  <96ff>     DW_AT_decl_file   : 225
  <9700>     DW_AT_decl_line   : 1066
  <9702>     DW_AT_type        : <ed>
  <9706>     DW_AT_data_member_location: 2 byte block: 23 2     (DW_OP_plus=
_uconst: 2)
 <2><9709>: Abbrev Number: 23 (DW_TAG_member)
  <970a>     DW_AT_name        : u
  <970c>     DW_AT_decl_file   : 225
  <970d>     DW_AT_decl_line   : 1067
  <970f>     DW_AT_type        : <956e>
  <9713>     DW_AT_data_member_location: 2 byte block: 23 8     (DW_OP_plus=
_uconst: 8)


The same structure from the 32-bit user space program (iwlist):

 <1><c3a>: Abbrev Number: 15 (DW_TAG_structure_type)
  <c3b>     DW_AT_sibling     : <c73>
  <c3f>     DW_AT_name        : (indirect string, offset: 0x32b): iw_event
  <c43>     DW_AT_byte_size   : 20
  <c44>     DW_AT_decl_file   : 96
  <c45>     DW_AT_decl_line   : 1095
 <2><c47>: Abbrev Number: 16 (DW_TAG_member)
  <c48>     DW_AT_name        : len
  <c4c>     DW_AT_decl_file   : 96
  <c4d>     DW_AT_decl_line   : 1096
  <c4f>     DW_AT_type        : <550>
  <c53>     DW_AT_data_member_location: 2 byte block: 23 0      (DW_OP_plus=
_uconst: 0)
 <2><c56>: Abbrev Number: 16 (DW_TAG_member)
  <c57>     DW_AT_name        : cmd
  <c5b>     DW_AT_decl_file   : 96
  <c5c>     DW_AT_decl_line   : 1097
  <c5e>     DW_AT_type        : <550>
  <c62>     DW_AT_data_member_location: 2 byte block: 23 2      (DW_OP_plus=
_uconst: 2)
 <2><c65>: Abbrev Number: 16 (DW_TAG_member)
  <c66>     DW_AT_name        : u
  <c68>     DW_AT_decl_file   : 96
  <c69>     DW_AT_decl_line   : 1098
  <c6b>     DW_AT_type        : <7e0>
  <c6f>     DW_AT_data_member_location: 2 byte block: 23 4      (DW_OP_plus=
_uconst: 4)

Compare the last lines of both (I'd have posted pahole output but the
dwarf lib it uses doesn't parse 64-bit binaries correctly when it is
compiled as a 32-bit binary.)=20

Now look at the definition of IW_EV_LCP_LEN. Or wait, how about we look
at the comment in front of it:

  /* Size of the Event prefix (including padding and alignement junk) */


Now, I don't know what gcc for ia64 does and I don't have a cross
compiler to check, but on powerpc it does this. I think the reason for
this here is iw_point again since it is part of the union iwreq_data
which means that the whole union requires 8-byte alignment on 64-bit
architectures where it's part of struct iw_event.

The easiest "fix" would be to make the structure packed, but existing
64-bit userspace expects the struct with padding while existing 32-bit
userspace (which of course includes 32-bit userspace running on 64-bit
machines) expects no padding... So that "fix" breaks all 64-bit
userspace, great.

Oh, btw, this also means that we have an information leak on 64-bit
kernels. Those alignment bytes aren't ever cleared or anything, they
come right from the stack since most users of this just use a struct
iw_event on the stack which is then memcpy()ed right into the userspace
buffer. For example those bytes 5 through 8 ("50:8A:35:E0") in the first
buffer above. This is generally considered a security problem.

Have fun...

johannes

--=-IXwO8PUpgVaVLp+Ovdez
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF8CAK/ETPhpq3jKURArKKAKC6XXQ5B5OaKEFeKa7iR3o+Ze5fXQCeLqIV
aCYqp4fPxzxP24ERdf1camQ=
=KtKV
-----END PGP SIGNATURE-----

--=-IXwO8PUpgVaVLp+Ovdez--
