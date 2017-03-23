From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [v2,net-next,1/3] net: stmmac: enable multiple buffers
Date: Thu, 23 Mar 2017 18:17:25 +0100
Message-ID: <20170323171725.GA12548@ulmo.ba.sec>
References: <1eb1ee4c84f61ff8dbc3f398f2e3f9b0bea3ee30.1489766674.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="C7zPtVaVf+AK4Oqc"
Cc: davem@davemloft.net, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33700 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751988AbdCWRRa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 13:17:30 -0400
Received: by mail-wm0-f68.google.com with SMTP id n11so462016wma.0
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 10:17:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1eb1ee4c84f61ff8dbc3f398f2e3f9b0bea3ee30.1489766674.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 17, 2017 at 04:11:05PM +0000, Joao Pinto wrote:
> This patch creates 2 new structures (stmmac_tx_queue and stmmac_rx_queue)
> in include/linux/stmmac.h, enabling that each RX and TX queue has its
> own buffers and data.
>=20
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
> changes v1->v2:
> - just to keep up version
>=20
>  drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |   45 +-
>  drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |   46 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   49 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 1306 ++++++++++++++-=
------
>  4 files changed, 973 insertions(+), 473 deletions(-)

Hi Joao,

This seems to break support on Tegra186 again. I've gone through this
patch multiple times and I can't figure out what could be causing it.
Any ideas?

What I'm seeing is that the transmit queue 0 times out:

	[  101.121774] Sending DHCP requests ...
	[  111.841763] NETDEV WATCHDOG: eth0 (dwc-eth-dwmac): transmit queue 0 tim=
ed out

and then I also see this:

	[  112.252024] dwc-eth-dwmac 2490000.ethernet: DMA-API: device driver trie=
s to free DMA memory it has not allocated [device address=3D0x0000000057ac6=
e9d] [size=3D0 bytes]
	[  112.266606] ------------[ cut here ]------------
	[  112.271220] WARNING: CPU: 0 PID: 0 at /home/thierry.reding/src/kernel/l=
inux-tegra.git/lib/dma-debug.c:1106 check_unmap+0x7b0/0x930
	[  112.282934] Modules linked in:
	[  112.285985]
	[  112.287474] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G S      W       4.1=
1.0-rc3-next-20170323-00060-g2eab4557749b-dirty #400
	[  112.298581] Hardware name: NVIDIA Tegra186 P2771-0000 Development Board=
 (DT)
	[  112.305615] task: ffff000008f87b00 task.stack: ffff000008f70000
	[  112.311523] PC is at check_unmap+0x7b0/0x930
	[  112.315785] LR is at check_unmap+0x7b0/0x930
	[  112.320046] pc : [<ffff0000083d75f0>] lr : [<ffff0000083d75f0>] pstate:=
 60000145
	[  112.327426] sp : ffff8001f5e50c50
	[  112.330733] x29: ffff8001f5e50c50 x28: ffff000008f75180
	[  112.336042] x27: ffff000008f87b00 x26: 0000000000000020
	[  112.341351] x25: 0000000000000140 x24: ffff000008f81000
	[  112.346660] x23: ffff8001ec4b0810 x22: 0000000057ac6e9d
	[  112.351969] x21: 0000000057ac6e9d x20: ffff8001f5e50cb0
	[  112.357277] x19: ffff8001ec4b0810 x18: 0000000000000010
	[  112.362586] x17: 00000000262ea01f x16: 000000000f48bf67
	[  112.367895] x15: 0000000000000006 x14: 5d64396536636137
	[  112.373203] x13: 3530303030303030 x12: 3078303d73736572
	[  112.378511] x11: 6464612065636976 x10: 65645b2064657461
	[  112.383819] x9 : ffff00000852c238 x8 : 00000000000001fb
	[  112.389126] x7 : 0000000000000000 x6 : ffff00000810ad58
	[  112.394434] x5 : 0000000000000000 x4 : 0000000000000000
	[  112.399743] x3 : ffffffffffffffff x2 : ffff000008f99258
	[  112.405050] x1 : ffff000008f87b00 x0 : 0000000000000097
	[  112.410358]
	[  112.411846] ---[ end trace 48028f96a0e990fb ]---
	[  112.416453] Call trace:
	[  112.418895] Exception stack(0xffff8001f5e50a80 to 0xffff8001f5e50bb0)
	[  112.425324] 0a80: ffff8001ec4b0810 0001000000000000 ffff8001f5e50c50 ff=
ff0000083d75f0
	[  112.433139] 0aa0: 00000000000001c0 0000000000000000 0000000000000000 ff=
ff000008d1c0c0
	[  112.440954] 0ac0: ffff8001f5e50c50 ffff8001f5e50c50 ffff8001f5e50c10 00=
000000ffffffc8
	[  112.448769] 0ae0: ffff8001f5e50b10 ffff00000810c3a8 ffff8001f5e50c50 ff=
ff8001f5e50c50
	[  112.456585] 0b00: ffff8001f5e50c10 00000000ffffffc8 ffff8001f5e50bc0 ff=
ff000008178388
	[  112.464399] 0b20: 0000000000000097 ffff000008f87b00 ffff000008f99258 ff=
ffffffffffffff
	[  112.472215] 0b40: 0000000000000000 0000000000000000 ffff00000810ad58 00=
00000000000000
	[  112.480030] 0b60: 00000000000001fb ffff00000852c238 65645b2064657461 64=
64612065636976
	[  112.487845] 0b80: 3078303d73736572 3530303030303030 5d64396536636137 00=
00000000000006
	[  112.495659] 0ba0: 000000000f48bf67 00000000262ea01f
	[  112.500528] [<ffff0000083d75f0>] check_unmap+0x7b0/0x930
	[  112.505830] [<ffff0000083d77d8>] debug_dma_unmap_page+0x68/0x70
	[  112.511744] [<ffff0000086a9654>] stmmac_free_tx_buffers.isra.1+0x114/0x=
198
	[  112.518604] [<ffff0000086a9754>] stmmac_tx_err+0x7c/0x160
	[  112.523993] [<ffff0000086a986c>] stmmac_tx_timeout+0x34/0x50
	[  112.529642] [<ffff0000088a1938>] dev_watchdog+0x270/0x2a8
	[  112.535032] [<ffff000008120774>] call_timer_fn+0x64/0xd0
	[  112.540334] [<ffff000008120890>] expire_timers+0xb0/0xc0
	[  112.545636] [<ffff0000081209f8>] run_timer_softirq+0x80/0xc0
	[  112.551284] [<ffff0000080c517c>] __do_softirq+0x10c/0x218
	[  112.556673] [<ffff0000080c55b0>] irq_exit+0xc8/0x118
	[  112.561629] [<ffff00000810cc50>] __handle_domain_irq+0x60/0xb8
	[  112.567450] [<ffff00000808154c>] gic_handle_irq+0x54/0xa8
	[  112.572837] Exception stack(0xffff000008f73dd0 to 0xffff000008f73f00)
	[  112.579264] 3dc0:                                   0000000000000000 00=
00000000000000
	[  112.587079] 3de0: 0000000000000001 0000000000000000 ffffffffffffea60 ff=
ff000008f73f00
	[  112.594894] 3e00: 00000000000000c0 0000000000000000 0000000000000028 ff=
ff000008f73e40
	[  112.602709] 3e20: 0000000000001130 00000000fa83b2da ffff000008a313a0 00=
00000000000001
	[  112.610524] 3e40: 0000000000000000 00000019ebd06fc0 000000000f48bf67 00=
000000262ea01f
	[  112.618338] 3e60: 0000000000000010 ffff000008f2b000 ffff000008f7eb58 ff=
ff000008f7e000
	[  112.626152] 3e80: ffff000008f371a0 0000000000000000 0000000000000000 ff=
ff000008f87b00
	[  112.633967] 3ea0: 00000000eff9cf10 0000000000000000 0000000080e60018 ff=
ff000008f73f00
	[  112.641782] 3ec0: ffff00000808524c ffff000008f73f00 ffff000008085250 00=
00000000000045
	[  112.649597] 3ee0: ffff000008f73f00 00000000ffff47c0 ffffffffffffffff 7f=
ffffffffffffff
	[  112.657411] [<ffff0000080827f4>] el1_irq+0xb4/0x128
	[  112.662280] [<ffff000008085250>] arch_cpu_idle+0x10/0x18
	[  112.667581] [<ffff0000080fbbdc>] do_idle+0x10c/0x1f0
	[  112.672537] [<ffff0000080fbeb8>] cpu_startup_entry+0x20/0x28
	[  112.678185] [<ffff000008a0aa64>] rest_init+0xbc/0xc8
	[  112.683140] [<ffff000008e60b4c>] start_kernel+0x384/0x398
	[  112.688528] [<ffff000008e601e0>] __primary_switched+0x64/0x6c

And finally this:

	[  112.694283] Unable to handle kernel paging request at virtual address f=
fff000008061000
	[  112.702184] pgd =3D ffff000009ae2000
	[  112.705577] [ffff000008061000] *pgd=3D0000000275f0e003, *pud=3D00000002=
75f0d003, *pmd=3D0000000275f0c003, *pte=3D0000000000000000
	[  112.716532] Internal error: Oops: 96000047 [#1] PREEMPT SMP
	[  112.722092] Modules linked in:
	[  112.725143] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G S      W       4.1=
1.0-rc3-next-20170323-00060-g2eab4557749b-dirty #400
	[  112.736248] Hardware name: NVIDIA Tegra186 P2771-0000 Development Board=
 (DT)
	[  112.743281] task: ffff000008f87b00 task.stack: ffff000008f70000
	[  112.749189] PC is at dwmac4_rd_init_tx_desc+0x0/0x10
	[  112.754142] LR is at stmmac_tx_err+0xe4/0x160
	[  112.758488] pc : [<ffff0000086b4790>] lr : [<ffff0000086a97bc>] pstate:=
 80000145
	[  112.765866] sp : ffff8001f5e50d80
	[  112.769171] x29: ffff8001f5e50d80 x28: ffff000008f75180
	[  112.774476] x27: ffff000008f87b00 x26: 0000000000000020
	[  112.779780] x25: 00000000ffffffff x24: 0000000000000000
	[  112.785086] x23: ffff8001eccbaac0 x22: 0000000000000000
	[  112.790389] x21: ffff8001e946a900 x20: ffff8001eccbaa00
	[  112.795694] x19: 0000000000000001 x18: 0000000000000010
	[  112.800998] x17: 00000000262ea01f x16: 000000000f48bf67
	[  112.806303] x15: 0000000000000006 x14: 5d64396536636137
	[  112.811608] x13: 3530303030303030 x12: 3078303d73736572
	[  112.816913] x11: 6464612065636976 x10: 65645b2064657461
	[  112.822218] x9 : ffff00000852c238 x8 : 0000000040000000
	[  112.827523] x7 : 0000000000210d00 x6 : ffff0000083d7038
	[  112.832828] x5 : ffff000008865ed8 x4 : 0000000000000080
	[  112.838133] x3 : ffff0000086b4790 x2 : 0000000000000000
	[  112.843438] x1 : 0000000000000000 x0 : ffff000008061000
	[  112.848743]
	[  112.850229] Process swapper/0 (pid: 0, stack limit =3D 0xffff000008f700=
00)
	[  112.856916] Stack: (0xffff8001f5e50d80 to 0xffff000008f74000)
	[  112.862647] Call trace:
	[  112.865087] Exception stack(0xffff8001f5e50bb0 to 0xffff8001f5e50ce0)
	[  112.871513] 0ba0:                                   0000000000000001 00=
01000000000000
	[  112.879326] 0bc0: ffff8001f5e50d80 ffff0000086b4790 ffff000008f87b00 00=
0000000001bbc0
	[  112.887139] 0be0: ffff000008f87b00 0000000000000020 ffff000008f87b00 ff=
ff000008f75180
	[  112.894952] 0c00: ffff000008fb8000 ffff000008f87b00 ffff000008f87b00 ff=
ff000008a117fc
	[  112.902766] 0c20: ffff8001e9721f00 ffff0000081d8684 ffff7e0007b12300 ff=
ff8001ec48d800
	[  112.910579] 0c40: ffff000008866308 000000018010000e ffff000008061000 00=
00000000000000
	[  112.918392] 0c60: 0000000000000000 ffff0000086b4790 0000000000000080 ff=
ff000008865ed8
	[  112.926206] 0c80: ffff0000083d7038 0000000000210d00 0000000040000000 ff=
ff00000852c238
	[  112.934018] 0ca0: 65645b2064657461 6464612065636976 3078303d73736572 35=
30303030303030
	[  112.941831] 0cc0: 5d64396536636137 0000000000000006 000000000f48bf67 00=
000000262ea01f
	[  112.949645] [<ffff0000086b4790>] dwmac4_rd_init_tx_desc+0x0/0x10
	[  112.955638] [<ffff0000086a986c>] stmmac_tx_timeout+0x34/0x50
	[  112.961285] [<ffff0000088a1938>] dev_watchdog+0x270/0x2a8
	[  112.966672] [<ffff000008120774>] call_timer_fn+0x64/0xd0
	[  112.971973] [<ffff000008120890>] expire_timers+0xb0/0xc0
	[  112.977274] [<ffff0000081209f8>] run_timer_softirq+0x80/0xc0
	[  112.982920] [<ffff0000080c517c>] __do_softirq+0x10c/0x218
	[  112.988307] [<ffff0000080c55b0>] irq_exit+0xc8/0x118
	[  112.993262] [<ffff00000810cc50>] __handle_domain_irq+0x60/0xb8
	[  112.999081] [<ffff00000808154c>] gic_handle_irq+0x54/0xa8
	[  113.004468] Exception stack(0xffff000008f73dd0 to 0xffff000008f73f00)
	[  113.010893] 3dc0:                                   0000000000000000 00=
00000000000000
	[  113.018706] 3de0: 0000000000000001 0000000000000000 ffffffffffffea60 ff=
ff000008f73f00
	[  113.026520] 3e00: 00000000000000c0 0000000000000000 0000000000000028 ff=
ff000008f73e40
	[  113.034335] 3e20: 0000000000001130 00000000fa83b2da ffff000008a313a0 00=
00000000000001
	[  113.042148] 3e40: 0000000000000000 00000019ebd06fc0 000000000f48bf67 00=
000000262ea01f
	[  113.049961] 3e60: 0000000000000010 ffff000008f2b000 ffff000008f7eb58 ff=
ff000008f7e000
	[  113.057775] 3e80: ffff000008f371a0 0000000000000000 0000000000000000 ff=
ff000008f87b00
	[  113.065590] 3ea0: 00000000eff9cf10 0000000000000000 0000000080e60018 ff=
ff000008f73f00
	[  113.073404] 3ec0: ffff00000808524c ffff000008f73f00 ffff000008085250 00=
00000000000045
	[  113.081217] 3ee0: ffff000008f73f00 00000000ffff47c0 ffffffffffffffff 7f=
ffffffffffffff
	[  113.089030] [<ffff0000080827f4>] el1_irq+0xb4/0x128
	[  113.093897] [<ffff000008085250>] arch_cpu_idle+0x10/0x18
	[  113.099197] [<ffff0000080fbbdc>] do_idle+0x10c/0x1f0
	[  113.104150] [<ffff0000080fbeb8>] cpu_startup_entry+0x20/0x28
	[  113.109798] [<ffff000008a0aa64>] rest_init+0xbc/0xc8
	[  113.114751] [<ffff000008e60b4c>] start_kernel+0x384/0x398
	[  113.120139] [<ffff000008e601e0>] __primary_switched+0x64/0x6c
	[  113.125874] Code: 7100003f 1a831042 b9000c02 d65f03c0 (29007c1f)
	[  113.131962] ---[ end trace 48028f96a0e990fc ]---

The above is with one small change already applied, which seemed like it
would be significant, but it didn't have much effect. See below...

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/=
net/ethernet/stmicro/stmmac/stmmac_main.c
[...]
> @@ -2977,14 +3356,22 @@ static int stmmac_rx(struct stmmac_priv *priv, in=
t limit)
>   */
>  static int stmmac_poll(struct napi_struct *napi, int budget)
>  {
> -	struct stmmac_priv *priv =3D container_of(napi, struct stmmac_priv, nap=
i);
> -	int work_done =3D 0;
> -	u32 chan =3D STMMAC_CHAN0;
> +	struct stmmac_rx_queue *rx_q =3D
> +		container_of(napi, struct stmmac_rx_queue, napi);
> +	struct stmmac_priv *priv =3D rx_q->priv_data;
> +	u32 tx_count =3D priv->dma_cap.number_tx_queues;

I changed this to priv->plat->tx_queues_to_use as used elsewhere to make
sure we don't try to clean up non-initialized TX queues. This seems to
solve an issue that would occasionally happen after the TX queue timed
out, but the fundamental issue is still there.

Thierry

--C7zPtVaVf+AK4Oqc
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljUAyIACgkQ3SOs138+
s6HZHg/+M9I2zJA692NnCQqxhCcmJOQn3wzTCSE6i72FKAWL6qDNnHGbnQZdvFSj
b/ZRVLmmhF5xJBaPnPGiHoOPovi0VSjALIzq1FocPdIeS1qmlMP+opF5YkkPtLL/
2Fp7Hb+lqR5fy1GgdXRO76xucp0Ky8L8IXm/d9tqlYML0dX9bVjwALAafAG/uk22
8VOgm8hXImjnv2ajZ9130rLxgNM3vDPM76RCx1tl6KGRPyOlkZ3cwdtduzWD6CSu
W6heqpNcAI7bSoPfpEQc+Fehx3FJn5RZ04+U6i92qQk4VcHHCk7dJeQsjN1JBB+g
cnHOla39C3FF8DrugFhuU1ipcwy34WDUYnYGfwUFELCQ/epQFlG5zLSh4YgT2si4
qjhHBZ8BAg+OLEFVC185hem4xRT/rdCH5ApU5ivk3o6uK7ImPoiFwb5EkVHAuM3q
yEJIszI/aFiDxoNKK3AKzHpKqo9wI+kkqOyEnizrhi7v4bIu1s19uNTV5pTfH9tY
Ki6ATIOs8L6XyYkRPIA6MKAPkJ8o0Y8Ihwd6QtdhqG+4BukqiX/O/G7rNDDdrfnF
KPfghtPKP6vF+71vsCQjCOw7rt3CmZgM/angEJs8pa4L9BzYhwnr5fC0iLk2uIJo
xtOGx1ed/AD4xq9mA9WA1YhBUv+FOBLKEMxol2v+knW8RESDQR8=
=xHZ6
-----END PGP SIGNATURE-----

--C7zPtVaVf+AK4Oqc--
