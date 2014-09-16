From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Tue, 16 Sep 2014 10:24:28 +1000
Message-ID: <20140916102428.5d1a3367@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/xpxdLrFlrwCQlt5dXD5+dnh"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anish Bhatt <anish@chelsio.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/xpxdLrFlrwCQlt5dXD5+dnh
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build
(powerpc ppc64_defconfig) failed like this:

warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && EIGER &=
& 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMII which=
 has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440EPX && 4=
40GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII which has =
unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) selects I=
BM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHERNET && =
NET_VENDOR_IBM)
warning: (SCSI_FC_ATTRS) selects SCSI_NETLINK which has unmet direct depend=
encies (NET)
warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX && 440SPe=
 && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 which has u=
nmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (SCSI_FC_ATTRS) selects SCSI_NETLINK which has unmet direct depend=
encies (NET)
warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440EPX && 4=
40GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII which has =
unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && EIGER &=
& 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMII which=
 has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) selects I=
BM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHERNET && =
NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX && 440SPe=
 && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 which has u=
nmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
drivers/built-in.o: In function `.scsi_nl_rcv_msg':
scsi_netlink.c:(.text+0x16455c): undefined reference to `.netlink_ack'
scsi_netlink.c:(.text+0x16456c): undefined reference to `.skb_pull'
scsi_netlink.c:(.text+0x1645e0): undefined reference to `.netlink_capable'
drivers/built-in.o: In function `.scsi_netlink_init':
(.text+0x16471c): undefined reference to `.__netlink_kernel_create'
drivers/built-in.o: In function `.scsi_netlink_exit':
(.text+0x16477c): undefined reference to `.netlink_kernel_release'
drivers/built-in.o: In function `.fc_host_post_event':
(.text+0x16ac1c): undefined reference to `.__alloc_skb'
drivers/built-in.o: In function `.fc_host_post_event':
(.text+0x16ac60): undefined reference to `.__nlmsg_put'
drivers/built-in.o: In function `.fc_host_post_event':
(.text+0x16ace0): undefined reference to `.netlink_broadcast'
drivers/built-in.o: In function `.fc_host_post_event':
(.text+0x16ad24): undefined reference to `.kfree_skb'
drivers/built-in.o: In function `.fc_host_post_vendor_event':
(.text+0x16ae48): undefined reference to `.__alloc_skb'
drivers/built-in.o: In function `.fc_host_post_vendor_event':
(.text+0x16ae90): undefined reference to `.__nlmsg_put'
drivers/built-in.o: In function `.fc_host_post_vendor_event':
(.text+0x16af1c): undefined reference to `.netlink_broadcast'
drivers/built-in.o: In function `.fc_host_post_vendor_event':
(.text+0x16af84): undefined reference to `.kfree_skb'
drivers/built-in.o:(.toc+0x0): undefined reference to `init_net'

Presumably caused by commit 5d6be6a5d486 ("scsi_netlink : Make
SCSI_NETLINK dependent on NET instead of selecting NET").

I used the version of the net tree from next-20140915 (i.e. up to
commit 9e07a422383c ("Merge branch 'bridge_vlan_filtering'")) for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/xpxdLrFlrwCQlt5dXD5+dnh
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUF4NDAAoJEMDTa8Ir7ZwVMQkP/2nJOBJ41gGiyc1Krt4mxpPv
QtpScVav2BmHxHOr9ihAcs2AV76nOiSy1Qeu6CMseQdpeQfZ+41KCPxwO0np4smE
yqyi+LyJ/dW0+YfoJfV8kjYgyLV+0Gt2Y9lx3qEoFJOyAtQVJeszS2YwG5uWwvVT
8mpClp97U8n7lM2ZEcqI65FpR1IOAkMi7Iv0TuByyYWlv+FPJG+uWCnQ5TBuDryc
MWP5mYlA6W5ut9yfnz2DWRngZJ38Vdknx7grWPROUL6bmpWzDriurpfNj7IDHd8g
Hco/CJ4yTqQDqIDQs1axq2jNpBfTk0WpDckCtUIputFisq0J1QJ1I5Qm53Dx3AnD
iiacATNKx8gWGHVaVUb5jOYw5twWSDuCg2C4pR4PGNuYPbgbB90alzs/GGfKu0Bq
7IK8F/PnhCZhnUU0vcs1nUj2E95F1gQxHcpKBUTyfvwd4PPHmtXAWoVR7Ds8Tl/R
LXSMAgiHU9D/l5YELsLmAdUN7qv249Z6ubAbvgEP+LfAnyrPNkdPLmHDMQIP4E2V
00X3Ydf6Pr2q4GmpOzQm0DXspEiuH8zhPiu8/hYTXPFd9rROBs6+Pg8q+NrJsJsv
qaM0uXXvqdEoIivpkF++20I/irfrnOGH7ppcapmMk8Omr2+/Fm7DAco08PqSsRDH
dTOkiyYX1bg34NtnyUFC
=v8Zm
-----END PGP SIGNATURE-----

--Sig_/xpxdLrFlrwCQlt5dXD5+dnh--
