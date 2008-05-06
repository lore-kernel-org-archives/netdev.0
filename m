From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Tue, 06 May 2008 13:13:08 +0200
Message-ID: <1210072389.13316.17.camel@johannes.berg>
References: <1210029835.8012.30.camel@johannes.berg>
	 <20080505.163916.239187195.davem@davemloft.net>
	 <1210032076.8012.49.camel@johannes.berg>
	 <20080505.170805.127854312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wLe7HruyrRYfdzCBEHrq"
Cc: tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080505.170805.127854312.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-wLe7HruyrRYfdzCBEHrq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-05-05 at 17:08 -0700, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Tue, 06 May 2008 02:01:16 +0200
>=20
> > Right. I just checked, and realised I remembered wrongly, wpa_supplican=
t
> > actually binds the socket to the ethertype it wants so
> > dev_queue_xmit_nit() shouldn't be called. I'll have to check why I got
> > so many cloned packets, best see if it still happens with the
> > header_cloned() change.
>=20
> skb_cloned() is fine, that's what every TCP packet is.
>=20
> skb_header_cloned() is what we expect to be false
>=20
> I look forward to the results of your investigation :-)

This is indeed the case. With that patch of yours (plus changes to make
it print out things) I occasionally see header-cloned SKBs [1] and due
to my spacing patch haven't yet seen one that didn't have enough
headroom. So this will optimise TCP a lot. I haven't tried bridging yet
as AP mode is rather unstable at the moment.

johannes

[1] those coming from ipv6, udp (possibly zeroconf stuff):

[34805.481404] MAC80211: got header cloned skb
[34805.481422]  [<c0272f78>] __copy_skb_header+0x1bc/0x20c
[34805.481449]  [<c0273084>] __skb_clone+0x2c/0xf4
[34805.481459]  [<c027b210>] dev_hard_start_xmit+0xf0/0x2f0
[34805.481473]  [<c028ed2c>] __qdisc_run+0x248/0x27c
[34805.481488]  [<c027baa0>] dev_queue_xmit+0x300/0x3cc
[34805.481498]  [<c02f0180>] ip6_output_finish+0xac/0x12c
[34805.481515]  [<c02f2ffc>] ip6_output+0x56c/0xe64
[34805.481524]  [<c02f1a78>] ip6_local_out+0x34/0x48
[34805.481533]  [<c02f1e50>] ip6_push_pending_frames+0x3c4/0x524
[34805.481542]  [<c0306ed8>] udp_v6_push_pending_frames+0x1e0/0x340
[34805.481559]  [<c03077e4>] udpv6_sendmsg+0x744/0xa24
[34805.481569]  [<c02cdad8>] inet_sendmsg+0x4c/0x78
[34805.481580]  [<c026bcc4>] sock_sendmsg+0xac/0xe4
[34805.481589]  [<c026bee0>] sys_sendmsg+0x1e4/0x2a0
[34805.481599]  [<c026cb48>] sys_socketcall+0xcc/0x1dc
[34805.481608]  [<c00124cc>] ret_from_syscall+0x0/0x38

[34789.711392] MAC80211: got header cloned skb
[34789.711411]  [<c0272f78>] __copy_skb_header+0x1bc/0x20c
[34789.711438]  [<c0273084>] __skb_clone+0x2c/0xf4
[34789.711448]  [<c027b210>] dev_hard_start_xmit+0xf0/0x2f0
[34789.711462]  [<c028ed2c>] __qdisc_run+0x248/0x27c
[34789.711478]  [<c027baa0>] dev_queue_xmit+0x300/0x3cc
[34789.711487]  [<c02a5c8c>] ip_finish_output+0x1e8/0x354
[34789.711504]  [<c02a61e8>] ip_local_out+0x34/0x48
[34789.711514]  [<c02a64a0>] ip_push_pending_frames+0x2a4/0x3d8
[34789.711525]  [<c02c52bc>] udp_push_pending_frames+0x128/0x39c
[34789.711543]  [<c02c6b7c>] udp_sendmsg+0x348/0x660
[34789.711553]  [<c02cdad8>] inet_sendmsg+0x4c/0x78
[34789.711564]  [<c026bcc4>] sock_sendmsg+0xac/0xe4
[34789.711574]  [<c026bee0>] sys_sendmsg+0x1e4/0x2a0
[34789.711583]  [<c026cb48>] sys_socketcall+0xcc/0x1dc
[34789.711593]  [<c00124cc>] ret_from_syscall+0x0/0x38


--=-wLe7HruyrRYfdzCBEHrq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASCA9Q6Vg1VMiehFYAQKj8xAAjgpxCnLpbiHxkFLB7zzU03p/IMc/YRiv
i9G+rmqJXnnpLG3khMzaKyiA10+BQwdXjDfwtBS/5wIeOmnvmEr/A074wXiFOjc9
MN+Oz99tM7nYjMDpBsNowrhQg+pvFWAS2y59uGdU9tU/K029Nk11kxybFsgbaUf+
acGMc3dYmJQrkMgy0vbzC4HUB25DBrUxheT8rPZSsp2bL2JNklG1beqt/b0tFscO
OzNxVH4YpXcDiqDk9tVFk20/ZNidRa2eCXP7x+lcQnn9HBc7tm+Fnn9zpg0u7WnR
g2WsCpK59Qz3jVDTgAb+I8DwSYsiz/s2437YgHRKTkBCjhWTz7MIuzhBNCQzkzK7
glQd1R9B15I7QgeKasSnYCaiW9N/nPXDXYG0BjMfMic9g0VnFW/XIbRO/AqTz6qb
xeErW2xXSETcqxFUirBLtq7r/+70JUVb9l0x9gwx6EtFv1ipCKirN57mDQKaBtUA
w2U+TqjWtLHA2TVljYzb5HJT1vjNKk6nuT/zm3CT/WrrawPAiVPjnVDC81aUeMdh
MvpLQhEIMz8wjKFH9OVBUNymNxx4NS+FIz/Yeqsxyw2qYqWQjrFyW/cft80YPCwj
W4S4tIQAdjDxPTnNQYY+2ieWRAvT8Du7p8oSVRJNy6p1SFzFiPsSHZx54ZF7x0sG
G0NmnhEewAc=
=T4e6
-----END PGP SIGNATURE-----

--=-wLe7HruyrRYfdzCBEHrq--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
