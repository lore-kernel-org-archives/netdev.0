From: Tomasz Torcz <zdzichu@irc.pl>
Subject: BUGs in skb_checksum_help() and skb_gso_segment() in 2.6.18-rc2
Date: Tue, 25 Jul 2006 17:15:04 +0200
Message-ID: <20060725151504.GA8947@irc.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UugvWAfsgieZRqgk"
Return-path: <netdev-owner@vger.kernel.org>
Received: from nsm.pl ([195.34.211.229]:33553 "EHLO nsm.pl")
	by vger.kernel.org with ESMTP id S932432AbWGYPPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 11:15:18 -0400
Received: from localhost (localhost [127.0.0.1])
	by nsm.pl (Postfix) with ESMTP id 18B762CAB24
	for <netdev@vger.kernel.org>; Tue, 25 Jul 2006 17:13:23 +0200 (CEST)
Received: from nsm.pl ([195.34.211.229])
 by localhost (nsm.pl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 19896-05 for <netdev@vger.kernel.org>;
 Tue, 25 Jul 2006 17:13:22 +0200 (CEST)
Received: from matthew.ogrody.nsm.pl (matthew.ogrody.nsm.pl [192.168.173.98])
	by nsm.pl (Postfix) with SMTP id 9E1002CAB10
	for <netdev@vger.kernel.org>; Tue, 25 Jul 2006 17:13:12 +0200 (CEST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


  Hi,

I just noticed in my logs following messages:

BUG: warning at net/core/dev.c:1171/skb_checksum_help()
 [<c010374a>] show_trace_log_lvl+0x51/0xe6
 [<c01037e9>] show_trace+0xa/0xc
 [<c01038b4>] dump_stack+0x13/0x15
 [<c02b41c4>] skb_checksum_help+0x4d/0xeb
 [<c02f9cbe>] ip_nat_fn+0x47/0x19a
 [<c02f9f83>] ip_nat_local_fn+0x3c/0xba
 [<c02c51dc>] nf_iterate+0x40/0x60
 [<c02c523e>] nf_hook_slow+0x42/0xa2
 [<c02cd6e7>] ip_queue_xmit+0x396/0x3e2
 [<c02db405>] tcp_transmit_skb+0x387/0x3a4
 [<c02dc74e>] tcp_push_one+0xaf/0xd3
 [<c02d32eb>] tcp_sendmsg+0x7ce/0x9b3
 [<c02e9a91>] inet_sendmsg+0x35/0x3f
 [<c02abea7>] sock_sendmsg+0xbf/0xd8
 [<c02acf03>] sys_sendto+0xe5/0x106
 [<c02acf3d>] sys_send+0x19/0x1d
 [<c02ad5e7>] sys_socketcall+0xf2/0x19b
 [<c0102a1b>] syscall_call+0x7/0xb
 [<47bb967e>] 0x47bb967e
BUG: warning at net/core/dev.c:1225/skb_gso_segment()
 [<c010374a>] show_trace_log_lvl+0x51/0xe6
 [<c01037e9>] show_trace+0xa/0xc
 [<c01038b4>] dump_stack+0x13/0x15
 [<c02b42ea>] skb_gso_segment+0x88/0x174
 [<c02b4483>] dev_gso_segment+0x5c/0x82
 [<c02b44f2>] dev_hard_start_xmit+0x49/0xaf
 [<c02beb99>] __qdisc_run+0x91/0x117
 [<c02b4679>] dev_queue_xmit+0x121/0x1ce
 [<c02cd31b>] ip_output+0x1a8/0x1de

 System is fairly standard x86 with e1000 card. 2.6.18-rc2.
# ethtool -k ep0
Offload parameters for ep0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on


--=20
Tomasz Torcz                "Funeral in the morning, IDE hacking
zdzichu@irc.-nie.spam-.pl    in the afternoon and evening." - Alan Cox


--UugvWAfsgieZRqgk
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (GNU/Linux)
Comment: gpg --search-keys Tomasz Torcz

iD8DBQFExjV4ThhlKowQALQRArSAAJ9PrB7yYGJixC6iDbjGDhVeVqDdhwCfVJI2
NBcRPR47q1Ur3OoiBHg6OLE=
=o5JY
-----END PGP SIGNATURE-----

--UugvWAfsgieZRqgk--
