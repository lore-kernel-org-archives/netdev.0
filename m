From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: linux kernel 4.6 and 4.7 from backports have bug in congestion
 module refcount
Date: Wed, 16 Nov 2016 15:12:41 +0000
Message-ID: <1479309161.3755.41.camel@decadent.org.uk>
References: <CAMig2e6C0Ga2oHiVGRrmQ_8Uw2AabWj7EyYyDDbHhxnMJSOWag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-6VEEoQcDqmBsU2n51FRb"
Cc: Panagiotis Malakoudis <malakudi@gmail.com>,
        Debian kernel maintainers <debian-kernel@lists.debian.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37511 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932605AbcKPPNB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 10:13:01 -0500
In-Reply-To: <CAMig2e6C0Ga2oHiVGRrmQ_8Uw2AabWj7EyYyDDbHhxnMJSOWag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6VEEoQcDqmBsU2n51FRb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

[Moving to netdev and debian-kernel lists]

On Wed, 2016-11-16 at 16:12 +0200, Panagiotis Malakoudis wrote:
> I am using Debian Jessie with backports and with the last kernels,
> 4.6.0-0.bpo.1 and 4.7.0-bpo.1 I experience the following WARNING after a
> few hours of heavy load tcp traffic.
>=20
> Nov 15 01:40:00 archive kernel: WARNING: CPU: 8 PID: 0 at /build/linux-lV=
EVrl/linux-4.7.8/kernel/module.c:1107 module_put+0x8d/0xa0
> Nov 15 01:40:00 archive kernel: Modules linked in: seqiv xfrm6_mode_tunne=
l xfrm4_mode_tunnel twofish_generic twofish_avx_x86_64 twofish_x86_64_3way =
twofish_x86_64 twofish_common serpent_avx2 serpent_avx_x86_64 serpent_sse2_=
x86_64 serpent_generic blowfish_generic blowfish_x86_64 blowfish_common cas=
t5_avx_x86_64 cast5_generic cast_common ctr ecb des_generic cbc algif_skcip=
her camellia_generic camellia_aesni_avx2 camellia_aesni_avx_x86_64 camellia=
_x86_64 xts xcbc sha512_ssse3 sha512_generic md4 algif_hash af_alg xfrm_use=
r xfrm4_tunnel ipcomp xfrm_ipcomp esp4 ah4 af_key xfrm_algo nfsd auth_rpcgs=
s nfs_acl nfs lockd grace fscache sunrpc ipip tunnel4 ip_tunnel xt_TCPMSS x=
t_tcpmss nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables xt_rec=
ent xt_tcpudp xt_policy nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_co=
nntrack
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0iptable_filter ip_tables x_tab=
les xfs libcrc32c crc32c_generic intel_rapl sb_edac edac_core x86_pkg_temp_=
thermal intel_powerclamp coretemp kvm_intel kvm irqbypass crct10dif_pclmul =
crc32_pclmul ghash_clmulni_intel iTCO_wdt iTCO_vendor_support jitterentropy=
_rng hmac drbg ansi_cprng aesni_intel ast aes_x86_64 lrw ttm gf128mul glue_=
helper ablk_helper cryptd drm_kms_helper pcspkr drm lpc_ich mfd_core i2c_i8=
01 sg mei_me joydev evdev ipmi_si mei ioatdma shpchp wmi button ipmi_msghan=
dler tpm_tis acpi_pad tpm acpi_power_meter tcp_htcp autofs4 ext4 crc16 jbd2=
 mbcache dm_mod md_mod hid_generic usbhid hid sd_mod crc32c_intel xhci_pci =
ahci xhci_hcd ehci_pci libahci ehci_hcd libata ixgbe mpt3sas igb usbcore ra=
id_class scsi_transport_sas i2c_algo_bit usb_common dca scsi_mod ptp pps_co=
re mdio fjes
> Nov 15 01:40:00 archive kernel: CPU: 8 PID: 0 Comm: swapper/8 Tainted: G =
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0W=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A04.=
7.0-0.bpo.1-amd64 #1 Debian 4.7.8-1~bpo8+1
> Nov 15 01:40:00 archive kernel: Hardware name: Supermicro Super Server/X1=
0SRH-CF, BIOS 1.0c 09/14/2015
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A00000000000000286 c4c1e09c90bba=
f17 ffffffffa3d1c805 0000000000000000
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A00000000000000000 ffffffffa3a7c=
9c4 ffff881024255000 ffffffffc032a0c0
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0ffff881024255130 0000000000000=
000 ffff881024255000 ffff881024255000
> Nov 15 01:40:00 archive kernel: Call Trace:
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0<IRQ>=C2=A0=C2=A0[<ffffffffa3d=
1c805>] ? dump_stack+0x5c/0x77
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3a7c9c4>] ? __warn+=
0xc4/0xe0
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3afe6dd>] ? module_=
put+0x8d/0xa0
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3f41ed0>] ? tcp_v4_=
destroy_sock+0x20/0x290
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3f292e7>] ? inet_cs=
k_destroy_sock+0x47/0x160
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3f38c37>] ? tcp_rcv=
_state_process+0xcc7/0xcd0
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3fd14e0>] ? tcp_v4_=
inbound_md5_hash+0x67/0x177
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3f41d20>] ? tcp_v4_=
do_rcv+0x70/0x200
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3f435e2>] ? tcp_v4_=
rcv+0x8a2/0xa90
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffc06fac01>] ? ipv4_co=
nfirm+0x61/0xf0 [nf_conntrack_ipv4]
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3f1d86b>] ? ip_loca=
l_deliver_finish+0x8b/0x1c0
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3f1db3b>] ? ip_loca=
l_deliver+0x6b/0xf0
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3f1d7e0>] ? ip_rcv_=
finish+0x3e0/0x3e0
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3f1de41>] ? ip_rcv+=
0x281/0x3b0
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3f1d400>] ? inet_de=
l_offload+0x40/0x40
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3edf11e>] ? __netif=
_receive_skb_core+0x2be/0xa50
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3f58865>] ? inet_gr=
o_receive+0x265/0x2a0
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3edf93f>] ? netif_r=
eceive_skb_internal+0x2f/0xa0
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3ee088b>] ? napi_gr=
o_receive+0xbb/0x110
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffc0332522>] ? ixgbe_c=
lean_rx_irq+0x542/0xaf0 [ixgbe]
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffc033381c>] ? ixgbe_p=
oll+0x44c/0x7a0 [ixgbe]
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3ee00e8>] ? net_rx_=
action+0x238/0x370
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3fe20b6>] ? __do_so=
ftirq+0x106/0x294
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3a82306>] ? irq_exi=
t+0x86/0x90
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3fe1dff>] ? do_IRQ+=
0x4f/0xd0
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3fdff42>] ? common_=
interrupt+0x82/0x82
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0<EOI>=C2=A0=C2=A0[<ffffffffa3e=
a38e2>] ? cpuidle_enter_state+0x112/0x260
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3abe31e>] ? cpu_sta=
rtup_entry+0x2be/0x360
> Nov 15 01:40:00 archive kernel:=C2=A0=C2=A0[<ffffffffa3a4e1c1>] ? start_s=
econdary+0x151/0x190
> Nov 15 01:40:00 archive kernel: ---[ end trace cdbbaec80305a0cc ]---
>=20
> Tracing the code I found that the issue comes from the usage of a tcp
> congestion module.
> I use sysctl -w net.ipv4.tcp_congestion_control=3Dhtcp, which is compiled=
 as
> module. Default congestion algo, cubic, is compiled inside kernel, not
> module.
>=20
> When the warning is triggered, /sys/module/tcp_htcp/refcnt is -1, which i=
s
> something that should not happen. It is triggered from inside
> tcp_v4_destroy_sock, when calling tcp_cleanup_congestion_control, which
> then calls module_put.
>=20
> This doesn't happen in 4.5.0-0.bpo.2 (2016-05-13) so I guess there is a b=
ug
> introduced from 4.5 to 4.6 which still lives in 4.7 and decrements
> reference count of htcp congestion module when it shouldn't. The issue is
> only triggered under heavy load (the above mentioned server is a 10g SFP+
> server with more than 4 Gbps traffic at certain times of day).

I didn't see any bug fixes relating to congestion control refcounts
after 4.7,=C2=A0so I'm guessing this bug is still present upstream.

Ben.

> I will test with a different congestion module (tcp_highspeed) to see if
> the issue is only htcp related or it is general issue of using congestion
> tcp modules.
>=20
> Panagiotis Malakoudis
--=20
Ben Hutchings
Time is nature's way of making sure that everything doesn't happen at
once.


--=-6VEEoQcDqmBsU2n51FRb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJYLHdpAAoJEOe/yOyVhhEJ38QQANC9CiuQR3citVB5X1Au/yAF
sZCNpKRoqg0dgwygUi6VZbCt2hO96fcO1JnubiB20+JmhWkm2EDAj1287UjplVYp
KsJU/GJrwU1XC0pkugKLpfUBo6vgwR2dCHmrIjM08LG6ZUWxMnYw6WtS5m3ImNx4
m1xOUCioXLYOGAL4CZqXhcyZKoxH3X9swngSuD0tk9n/dSa6UnGZvHE7jPpYa+xt
Vhisd4g0uRXGYb9tp/lzS4OdPTOsAH7GeXXfC8v6gW4SLB/Z5EY82R/nP+nzDubj
prEe5QfygOeJCCsNgNdKbQXB5gf+K/wo0BVEvwaz76MxJ5BM3aofWvvorJ4Tn+8z
Nmdo+2HerzgflJwToEweVFzrYIGtto/gFmjCcqHwWJq2bITqOymBh7p5Ok1Sc8ep
ZyDXT3Dmhe1yCAxwBLkNDXK8sqcmxBNQ5k4jrYxlO87UyrSWUbiWR1mc/CPTqeA7
EJbZ6ilEfakQlkiPa2+3euIBXXZt+1JBgLPXrLDUMIwQ7mtzqvu4ApRnWD+DGcW1
gblfuNqMf6+Nvllz4on3bI8NNL3cxKpIxGsp3lj0wkLgGEkjSqXOPEZ6Y7kN8dDX
Ru17hwuJ8JJTdMqBswyC5iBWE2qWDFkDI7V6RyoGcnQ5v6AzJ+XPcU0sOybfD7gX
kdIgGCZGc+7fS8xE81nW
=D8eN
-----END PGP SIGNATURE-----

--=-6VEEoQcDqmBsU2n51FRb--
