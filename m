From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: drop zero length frame segments during a packet
 split rx
Date: Tue, 13 Sep 2011 15:52:02 -0700
Message-ID: <1315954323.3661.9.camel@jtkirshe-mobl>
References: <1314972197-31557-1-git-send-email-nhorman@tuxdriver.com>
	 <20110913105003.GA16222@hmsreliant.think-freely.org>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-68cV1QJy/RJCL7xibmq8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36945 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932984Ab1IMWwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Sep 2011 18:52:04 -0400
In-Reply-To: <20110913105003.GA16222@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-68cV1QJy/RJCL7xibmq8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-09-13 at 03:50 -0700, Neil Horman wrote:
> On Fri, Sep 02, 2011 at 10:03:17AM -0400, Neil Horman wrote:
> > This oops was reported recently no ppc64 hardware:
> > Unable to handle kernel paging request for data at address 0x00000000
> > Faulting instruction address: 0xc0000000004dda0c
> > Oops: Kernel access of bad area, sig: 11 [#1]
> > SMP NR_CPUS=3D1024 NUMA pSeries
> > Modules linked in: sunrpc ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4
> > iptable_fi
> > lter ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state
> > nf_conntrack ip6table_filter ip6_tables ipv6 jsm ses enclosure sg ixgbe
> > mdio e1000 ehea ext4 jbd2 mbcache sd_mod crc_t10dif ipr dm_mod
> > NIP: c0000000004dda0c LR: c0000000004e3e50 CTR: c0000000004e3e20
> > REGS: c0000001bffeb8d0 TRAP: 0300   Not tainted  (3.1.0-rc2-10121-gab7e=
2db)
> > MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 28002042  XER: 20000000
> > CFAR: c000000000004d70
> > DAR: 0000000000000000, DSISR: 40000000
> > TASK =3D c000000000d548e0[0] 'swapper' THREAD: c000000000dfc000 CPU: 0
> > GPR04: c0000000010f4d80 c0000001bffebd80 0000000000000000 c0000001b18a8=
200
> > GPR08: 0000000000000280 c0000001bcc517a8 c0000001b18a7f80 0000000000000=
000
> > GPR12: d0000000047e5bb0 c000000001f10000 c0000001b19c8700 0000000000000=
000
> > GPR16: c0000001bffebd80 0000000000000083 c00000018f2447a0 0000000000000=
002
> > GPR20: 0000000000000000 c0000001ba860010 c0000001ba860000 d000000003d40=
000
> > GPR24: 0000000000000000 0000000000000083 d000000003d40000 0000000000000=
001
> > GPR28: c00000018f244780 c0000001b2b94310 c000000000da95f0 c0000001bcc51=
780
> > NIP [c0000000004dda0c] .skb_gro_reset_offset+0x5c/0xe0
> > LR [c0000000004e3e50] .napi_gro_receive+0x30/0x120
> > Call Trace:
> > [c0000001bffebb50] [c000000000da95f0] perf_callchain_user+0x0/0x10 (unr=
eliable)
> > [c0000001bffebbf0] [d0000000047bd118] .ixgbe_clean_rx_irq+0x7a8/0x8a0 [=
ixgbe]
> > [c0000001bffebd10] [d0000000047bd414] .ixgbe_poll+0x64/0x160 [ixgbe]
> > [c0000001bffebdd0] [c0000000004e3358] .net_rx_action+0x108/0x2a0
> > [c0000001bffebea0] [c00000000009b220] .__do_softirq+0x110/0x2a0
> > [c0000001bffebf90] [c000000000023798] .call_do_softirq+0x14/0x24
> > [c000000000dff830] [c000000000011148] .do_softirq+0xf8/0x130
> > [c000000000dff8d0] [c00000000009aeb4] .irq_exit+0xb4/0xc0
> > [c000000000dff950] [c000000000011254] .do_IRQ+0xd4/0x300
> > [c000000000dffa10] [c000000000005024] hardware_interrupt_entry+0x18/0x7=
4
> > --- Exception: 501 at .pseries_dedicated_idle_sleep+0xe4/0x210
> > LR =3D .pseries_dedicated_idle_sleep+0x8c/0x210
> > [c000000000dffd00] [c00000000005b194] .pseries_dedicated_idle_sleep+0x1=
94/0x210
> > (unreliable)
> > [c000000000dffdc0] [c000000000018c84] .cpu_idle+0x164/0x210
> > [c000000000dffe70] [c00000000000b0d0] .rest_init+0x90/0xb0
> > [c000000000dffef0] [c000000000830bc0] .start_kernel+0x54c/0x56c
> > [c000000000dfff90] [c00000000000953c] .start_here_common+0x1c/0x60
> >=20
> > Its caused when skb_gro_reset_offset attempts to call PageHighMem on
> > skb_shinfo(skb)->frags[0].page, when the frags array was left uninitali=
zed.
> > This can happen in the ixgbe driver if the hardware reports a zero leng=
th rx
> > descriptor ni the middle of a packet split receive transaction.  I've c=
onsulted
> > with Jesse Brandeburg on this, who is attempting to root cause the issu=
e at
> > Intel, but it seems prudent to add this check to the driver to discard =
frames of
> > that encounter this error to avoid the opps
> >=20
> Sorry, I need to rescind this patch.  Looks like this is turning out to b=
e an
> issue with an ideosyncracy in the dma hardware on this platform.
>=20
> Thanks
> Neil
>=20

Thanks for the update Neil.  I have dropped the patch from my queue.

--=-68cV1QJy/RJCL7xibmq8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOb96SAAoJECTsCADr/EWUQecH/1ebSJXqPwtH4mo5IuYb/gWZ
FDz86Mcma0PNAio8uvyr7jp1sx6RzFJcBVmv/cR65tD/76qpASrkMP8gxpBiZzd5
yVgloeUoIHlIVsdi9BpOMcKFtw9Q0MFKm9V3CYLpX3zdDsBik/C6Bg5KkRYb5yXQ
SdSqfiTOAspeF6YgCVfiufLkpd3Kt3k8QpupW9LYCbni0kFaipM4S/CiYZbtC2gL
kwvFR0IQLPobOovvCWzko5XS9PgpNbSj9yNC1RxGdvzo2LIVu7O7lOv7K76xhBEO
1FGsS0wOqFQku7bdN3bS3+TH+wWHlQwbIsmCN/YKyoSTCW9yem9dwDpUMH88XbA=
=d0zs
-----END PGP SIGNATURE-----

--=-68cV1QJy/RJCL7xibmq8--
