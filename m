From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: drop zero length frame segments during a packet
 split rx
Date: Fri, 02 Sep 2011 09:04:53 -0700
Message-ID: <1314979493.3532.4.camel@jtkirshe-linux>
References: <1314972197-31557-1-git-send-email-nhorman@tuxdriver.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-q77cvLgmnPtGX8y43OGP"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55452 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753154Ab1IBQEy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Sep 2011 12:04:54 -0400
In-Reply-To: <1314972197-31557-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-q77cvLgmnPtGX8y43OGP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-09-02 at 07:03 -0700, Neil Horman wrote:
> This oops was reported recently no ppc64 hardware:
> Unable to handle kernel paging request for data at address 0x00000000
> Faulting instruction address: 0xc0000000004dda0c
> Oops: Kernel access of bad area, sig: 11 [#1]
> SMP NR_CPUS=3D1024 NUMA pSeries
> Modules linked in: sunrpc ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4
> iptable_fi
> lter ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state
> nf_conntrack ip6table_filter ip6_tables ipv6 jsm ses enclosure sg
> ixgbe
> mdio e1000 ehea ext4 jbd2 mbcache sd_mod crc_t10dif ipr dm_mod
> NIP: c0000000004dda0c LR: c0000000004e3e50 CTR: c0000000004e3e20
> REGS: c0000001bffeb8d0 TRAP: 0300   Not tainted
> (3.1.0-rc2-10121-gab7e2db)
> MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 28002042  XER: 20000000
> CFAR: c000000000004d70
> DAR: 0000000000000000, DSISR: 40000000
> TASK =3D c000000000d548e0[0] 'swapper' THREAD: c000000000dfc000 CPU: 0
> GPR04: c0000000010f4d80 c0000001bffebd80 0000000000000000
> c0000001b18a8200
> GPR08: 0000000000000280 c0000001bcc517a8 c0000001b18a7f80
> 0000000000000000
> GPR12: d0000000047e5bb0 c000000001f10000 c0000001b19c8700
> 0000000000000000
> GPR16: c0000001bffebd80 0000000000000083 c00000018f2447a0
> 0000000000000002
> GPR20: 0000000000000000 c0000001ba860010 c0000001ba860000
> d000000003d40000
> GPR24: 0000000000000000 0000000000000083 d000000003d40000
> 0000000000000001
> GPR28: c00000018f244780 c0000001b2b94310 c000000000da95f0
> c0000001bcc51780
> NIP [c0000000004dda0c] .skb_gro_reset_offset+0x5c/0xe0
> LR [c0000000004e3e50] .napi_gro_receive+0x30/0x120
> Call Trace:
> [c0000001bffebb50] [c000000000da95f0] perf_callchain_user+0x0/0x10
> (unreliable)
> [c0000001bffebbf0] [d0000000047bd118] .ixgbe_clean_rx_irq+0x7a8/0x8a0
> [ixgbe]
> [c0000001bffebd10] [d0000000047bd414] .ixgbe_poll+0x64/0x160 [ixgbe]
> [c0000001bffebdd0] [c0000000004e3358] .net_rx_action+0x108/0x2a0
> [c0000001bffebea0] [c00000000009b220] .__do_softirq+0x110/0x2a0
> [c0000001bffebf90] [c000000000023798] .call_do_softirq+0x14/0x24
> [c000000000dff830] [c000000000011148] .do_softirq+0xf8/0x130
> [c000000000dff8d0] [c00000000009aeb4] .irq_exit+0xb4/0xc0
> [c000000000dff950] [c000000000011254] .do_IRQ+0xd4/0x300
> [c000000000dffa10] [c000000000005024] hardware_interrupt_entry
> +0x18/0x74
> --- Exception: 501 at .pseries_dedicated_idle_sleep+0xe4/0x210
> LR =3D .pseries_dedicated_idle_sleep+0x8c/0x210
> [c000000000dffd00] [c00000000005b194] .pseries_dedicated_idle_sleep
> +0x194/0x210
> (unreliable)
> [c000000000dffdc0] [c000000000018c84] .cpu_idle+0x164/0x210
> [c000000000dffe70] [c00000000000b0d0] .rest_init+0x90/0xb0
> [c000000000dffef0] [c000000000830bc0] .start_kernel+0x54c/0x56c
> [c000000000dfff90] [c00000000000953c] .start_here_common+0x1c/0x60
>=20
> Its caused when skb_gro_reset_offset attempts to call PageHighMem on
> skb_shinfo(skb)->frags[0].page, when the frags array was left
> uninitalized.
> This can happen in the ixgbe driver if the hardware reports a zero
> length rx
> descriptor ni the middle of a packet split receive transaction.  I've
> consulted
> with Jesse Brandeburg on this, who is attempting to root cause the
> issue at
> Intel, but it seems prudent to add this check to the driver to discard
> frames of
> that encounter this error to avoid the opps
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Thadeu Lima de Souza Cascardo
> <cascardo@linux.vnet.ibm.com>
> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Alexander Duyck <alexander.h.duyck@intel.com>
> CC: John Fastabend <john.r.fastabend@intel.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   17
> +++++++++++------
>  1 files changed, 11 insertions(+), 6 deletions(-)=20

Thanks Neil, I have added the patch to my queue of ixgbe patches.

This patch was made against net-next, was this issue only seen on the
net-next kernel?

--=-q77cvLgmnPtGX8y43OGP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOYP6lAAoJECTsCADr/EWUw1IH/3RZ9EU4oXcpwjKu0o5Gq3Nz
pJWPeGZDepku0oLbJtsbj5sXYjFSOoj7tBj8PxV3RdMllWCN9iPTxMdW0/nThojk
+p/9jzizTJKNoRucQmsQiZ04DsA0Zkipq+NjgFFKNPbumP6cSWqzAdcVO41JxHO3
ejYvwD5xtDPwFPGRWFGclEr++lGG9fnM5ysXSmj4Bml0qGGiUjJ41dM0UmZQ2LwV
J+yUMjKa0VGDSq/wJZ4nX66PbAfjxYHYBSk+8Z2YFzEsNU9cNra3YyxdckWJni+E
BJYGz5gASV0XcOVb38PtQfpLe3r5IA9kubRwuVR0Chh+7b7MiNOpQny+okqsDWc=
=LHcW
-----END PGP SIGNATURE-----

--=-q77cvLgmnPtGX8y43OGP--
