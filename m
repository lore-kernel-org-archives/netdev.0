From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: d80211: How does TX flow control work?
Date: Wed, 03 Jan 2007 19:10:01 +0100
Message-ID: <459BF179.6000906@web.de>
References: <459A5945.80909@web.de> <20070103185203.2754e059@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6416FD2FB759A9A9E6229B2D"
Cc: netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:41416 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbXACSKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 13:10:06 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20070103185203.2754e059@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6416FD2FB759A9A9E6229B2D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Jiri Benc wrote:

> On Tue, 02 Jan 2007 14:08:21 +0100, Jan Kiszka wrote:
>  =20
>> What I (think to) understand is that a low-level drivers call
>> ieee80211_stop_queue() if they run out of buffers. That flips a
>> per-queue bit (IEEE80211_LINK_STATE_XOFF), prevents that any further
>> frame is passed to the low-level TX routine,
>>    =20
>
> Correct.
>
>  =20
>> and can cause that up to
>> *one* packet per queue is stored in
>> ieee80211_local::pending_packets[queue].
>>    =20
>
> This is needed due to fragmented frames. After resume, passing of
> fragments to the driver has to continue where it was stopped. Returning=

> the half-sent fragmented frame to the 802.11 qdisc wasn't possible
> until recently (I think the conversion of master interface to native
> 802.11 type could allow that now - but it's probably not worth the
> effort).
>
>  =20
>> But it looks to me like nothing
>> prevents ieee80211_tx() being invoked even in case that there is alrea=
dy
>> some stuff in that single-packet storage.
>>    =20
>
> The 802.11 qdisc (see wme_qdiscop_dequeue) takes care of that.
>
>  =20
Ahh, that is an interesting new piece in the puzzle.


>> That in turn triggers WARN_ONs in ieee80211_tx() under high load for m=
e
>> (with rt2500usb). And it should also cause orphaned skbs because the
>> storage is overwritten in that case. Either I'm blind or something is
>> fishy...
>>    =20
>
> You are most likely hitting some bug. Could you post more information
> please?
>
>  =20
Test scenario is rt2500usb from the rt2x00 CVS (+my currently half-pendin=
g
series), an ASUS WL167g USB stick, and hostapd driving that stick in mast=
er
mode. As soon as I trigger the AP to send out some longer TCP stream, I g=
et
these warnings:

BUG: warning at /usr/src/rt2x00/rt2x00/ieee80211/ieee80211.c:1256/ieee802=
11_tx()
 <cfa02245> ieee80211_master_start_xmit+0x105/0x430 [80211]  <c024e35d> _=
_ip_ct_refresh_acct+0x4d/0x60
 <c024fd11> tcp_packet+0x941/0x970  <c0217442> qdisc_restart+0x92/0x100
 <c020d43d> dev_queue_xmit+0xbd/0x1a0  <cfa050d8> ieee80211_subif_start_x=
mit+0x468/0x480 [80211]
 <c0207dca> skb_clone+0x3a/0x1a0  <c021d16d> nf_hook_slow+0x4d/0xc0
 <c020d495> dev_queue_xmit+0x115/0x1a0  <c0226a63> ip_output+0x1c3/0x200
 <c0225740> ip_finish_output+0x0/0x180  <c022628b> ip_queue_xmit+0x36b/0x=
3b0
 <c0224130> dst_output+0x0/0x10  <ce9bae7d> usb_hcd_giveback_urb+0x2d/0x6=
0 [usbcore]
 <c0237da2> tcp_v4_send_check+0x82/0xd0  <c0237da2> tcp_v4_send_check+0x8=
2/0xd0
 <c0233244> tcp_transmit_skb+0x5e4/0x610  <c0234b36> __tcp_push_pending_f=
rames+0x676/0x740
 <c0207f81> __alloc_skb+0x51/0x100  <c022b817> tcp_sendmsg+0x897/0x980
 <c0153fa9> core_sys_select+0x1b9/0x2b0  <c0241f1d> inet_sendmsg+0x3d/0x5=
0
 <c0202a8f> do_sock_write+0x8f/0xa0  <c020301f> sock_aio_write+0x5f/0x70
 <c01443d3> do_sync_write+0xc3/0x100  <c01247f0> autoremove_wake_function=
+0x0/0x40
 <c0144ca1> vfs_write+0xa1/0x140  <c01451d3> sys_write+0x43/0x70
 <c0102ae7> syscall_call+0x7/0xb

Does it tell you anything already? Is there something I may instrument? W=
hat
could the driver do wrong to trigger such bug?

Jan



--------------enig6416FD2FB759A9A9E6229B2D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFFm/F5niDOoMHTA+kRAkMKAJ9W1AgAYIZjTtAix6lAK9e87yzf9QCfShXe
bK/Rug7mgc7MUV0cwlr9Wgc=
=Tt4i
-----END PGP SIGNATURE-----

--------------enig6416FD2FB759A9A9E6229B2D--
