From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: d80211: How does TX flow control work?
Date: Mon, 08 Jan 2007 21:18:48 +0100
Message-ID: <45A2A728.1070404@web.de>
References: <459A5945.80909@web.de>	<20070103185203.2754e059@griffin.suse.cz>	<459BF179.6000906@web.de> <20070103191853.4f440b8b@griffin.suse.cz> <459BFB05.9040608@web.de> <45A03825.9080807@web.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB0B74CBD4EA1856D69066EAC"
Cc: netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:57685 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932070AbXAHUSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 15:18:51 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <45A03825.9080807@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB0B74CBD4EA1856D69066EAC
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Jan Kiszka wrote:
> Jan Kiszka wrote:
>> Jiri Benc wrote:
>>> On Wed, 03 Jan 2007 19:10:01 +0100, Jan Kiszka wrote:
>>>> BUG: warning at /usr/src/rt2x00/rt2x00/ieee80211/ieee80211.c:1256/ie=
ee80211_tx()
>>>>  <cfa02245> ieee80211_master_start_xmit+0x105/0x430 [80211]  <c024e3=
5d> __ip_ct_refresh_acct+0x4d/0x60
>>>>  <c024fd11> tcp_packet+0x941/0x970  <c0217442> qdisc_restart+0x92/0x=
100
>>>>  <c020d43d> dev_queue_xmit+0xbd/0x1a0  <cfa050d8> ieee80211_subif_st=
art_xmit+0x468/0x480 [80211]
>>>>  <c0207dca> skb_clone+0x3a/0x1a0  <c021d16d> nf_hook_slow+0x4d/0xc0
>>>>  <c020d495> dev_queue_xmit+0x115/0x1a0  <c0226a63> ip_output+0x1c3/0=
x200
>>>>  <c0225740> ip_finish_output+0x0/0x180  <c022628b> ip_queue_xmit+0x3=
6b/0x3b0
>>>>  <c0224130> dst_output+0x0/0x10  <ce9bae7d> usb_hcd_giveback_urb+0x2=
d/0x60 [usbcore]
>>>>  <c0237da2> tcp_v4_send_check+0x82/0xd0  <c0237da2> tcp_v4_send_chec=
k+0x82/0xd0
>>>>  <c0233244> tcp_transmit_skb+0x5e4/0x610  <c0234b36> __tcp_push_pend=
ing_frames+0x676/0x740
>>>>  <c0207f81> __alloc_skb+0x51/0x100  <c022b817> tcp_sendmsg+0x897/0x9=
80
>>>>  <c0153fa9> core_sys_select+0x1b9/0x2b0  <c0241f1d> inet_sendmsg+0x3=
d/0x50
>>>>  <c0202a8f> do_sock_write+0x8f/0xa0  <c020301f> sock_aio_write+0x5f/=
0x70
>>>>  <c01443d3> do_sync_write+0xc3/0x100  <c01247f0> autoremove_wake_fun=
ction+0x0/0x40
>>>>  <c0144ca1> vfs_write+0xa1/0x140  <c01451d3> sys_write+0x43/0x70
>>>>  <c0102ae7> syscall_call+0x7/0xb
>>>>
>>>> Does it tell you anything already? Is there something I may instrume=
nt? What
>>>> could the driver do wrong to trigger such bug?
>>> Do you have CONFIG_NET_SCHED enabled?
>>>
>=20
> Sorry, this was most probably false alarm for the official stack. The
> problem now appears to be related to a patch against d80211 that is onl=
y
> present in the rt2x00 CVS.

Well, I said "most probably"...

The actual problem was meanwhile identified: shorewall happened to
overwrite the queueing discipline of wmaster0 with pfifo_fast. I found
the magic knob to tell shorewall to no longer do this (at least until I
want to manage traffic control that way...), but I still wonder if it is
an acceptable situation. Currently, the user can intentionally or
accidentally screw up the stack this way.

Jan


PS: Tests performed on a 2.6.17 kernel, but I don't see a reason why
newer kernels should be immune.


--------------enigB0B74CBD4EA1856D69066EAC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFFoqconiDOoMHTA+kRAkT4AJsHeYWqGKgDF0mmq4yvBu3CG5kHJwCfQiaL
U/m1niElmAcl+emkyDWrohY=
=4EfD
-----END PGP SIGNATURE-----

--------------enigB0B74CBD4EA1856D69066EAC--
