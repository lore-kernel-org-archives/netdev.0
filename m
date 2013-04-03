From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] e100: Add dma mapping error check
Date: Wed, 03 Apr 2013 14:13:15 -0700
Message-ID: <1365023595.2089.9.camel@jtkirshe-mobl>
References: <1364923838-14271-1-git-send-email-nhorman@tuxdriver.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gHaNfUk9vSTsB92/Lfkp"
Cc: netdev@vger.kernel.org, Josh Boyer <jwboyer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18945 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760401Ab3DCVNj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Apr 2013 17:13:39 -0400
In-Reply-To: <1364923838-14271-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gHaNfUk9vSTsB92/Lfkp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-04-02 at 13:30 -0400, Neil Horman wrote:
> e100 uses pci_map_single, but fails to check for a dma mapping error
> after its
> use, resulting in a stack trace:
>=20
> [   46.656594] ------------[ cut here ]------------
> [   46.657004] WARNING: at lib/dma-debug.c:933 check_unmap
> +0x47b/0x950()
> [   46.657004] Hardware name: To Be Filled By O.E.M.
> [   46.657004] e100 0000:00:0e.0: DMA-API: device driver failed to
> check map
> error[device address=3D0x000000007a4540fa] [size=3D90 bytes] [mapped as
> single]
> [   46.657004] Modules linked in:
> [   46.657004]  w83627hf hwmon_vid snd_via82xx ppdev snd_ac97_codec
> ac97_bus
> snd_seq snd_pcm snd_mpu401 snd_mpu401_uart ns558 snd_rawmidi gameport
> parport_pc
> e100 snd_seq_device parport snd_page_alloc snd_timer snd soundcore
> skge shpchp
> k8temp mii edac_core i2c_viapro edac_mce_amd nfsd auth_rpcgss nfs_acl
> lockd
> sunrpc binfmt_misc uinput ata_generic pata_acpi radeon i2c_algo_bit
> drm_kms_helper ttm firewire_ohci drm firewire_core pata_via sata_via
> i2c_core
> sata_promise crc_itu_t
> [   46.657004] Pid: 792, comm: ip Not tainted
> 3.8.0-0.rc6.git0.1.fc19.x86_64 #1
> [   46.657004] Call Trace:
> [   46.657004]  <IRQ>  [<ffffffff81065ed0>] warn_slowpath_common
> +0x70/0xa0
> [   46.657004]  [<ffffffff81065f4c>] warn_slowpath_fmt+0x4c/0x50
> [   46.657004]  [<ffffffff81364cfb>] check_unmap+0x47b/0x950
> [   46.657004]  [<ffffffff8136522f>] debug_dma_unmap_page+0x5f/0x70
> [   46.657004]  [<ffffffffa030f0f0>] ? e100_tx_clean+0x30/0x210 [e100]
> [   46.657004]  [<ffffffffa030f1a8>] e100_tx_clean+0xe8/0x210 [e100]
> [   46.657004]  [<ffffffffa030fc6f>] e100_poll+0x56f/0x6c0 [e100]
> [   46.657004]  [<ffffffff8159dce1>] ? net_rx_action+0xa1/0x370
> [   46.657004]  [<ffffffff8159ddb2>] net_rx_action+0x172/0x370
> [   46.657004]  [<ffffffff810703bf>] __do_softirq+0xef/0x3d0
> [   46.657004]  [<ffffffff816e4ebc>] call_softirq+0x1c/0x30
> [   46.657004]  [<ffffffff8101c485>] do_softirq+0x85/0xc0
> [   46.657004]  [<ffffffff81070885>] irq_exit+0xd5/0xe0
> [   46.657004]  [<ffffffff816e5756>] do_IRQ+0x56/0xc0
> [   46.657004]  [<ffffffff816dacb2>] common_interrupt+0x72/0x72
> [   46.657004]  <EOI>  [<ffffffff816da1eb>] ?
> _raw_spin_unlock_irqrestore+0x3b/0x70
> [   46.657004]  [<ffffffff816d124d>] __slab_free+0x58/0x38b
> [   46.657004]  [<ffffffff81214424>] ? fsnotify_clear_marks_by_inode
> +0x34/0x120
> [   46.657004]  [<ffffffff811b0417>] ? kmem_cache_free+0x97/0x320
> [   46.657004]  [<ffffffff8157fc14>] ? sock_destroy_inode+0x34/0x40
> [   46.657004]  [<ffffffff8157fc14>] ? sock_destroy_inode+0x34/0x40
> [   46.657004]  [<ffffffff811b0692>] kmem_cache_free+0x312/0x320
> [   46.657004]  [<ffffffff8157fc14>] sock_destroy_inode+0x34/0x40
> [   46.657004]  [<ffffffff811e8c28>] destroy_inode+0x38/0x60
> [   46.657004]  [<ffffffff811e8d5e>] evict+0x10e/0x1a0
> [   46.657004]  [<ffffffff811e9605>] iput+0xf5/0x180
> [   46.657004]  [<ffffffff811e4338>] dput+0x248/0x310
> [   46.657004]  [<ffffffff811ce0e1>] __fput+0x171/0x240
> [   46.657004]  [<ffffffff811ce26e>] ____fput+0xe/0x10
> [   46.657004]  [<ffffffff8108d54c>] task_work_run+0xac/0xe0
> [   46.657004]  [<ffffffff8106c6ed>] do_exit+0x26d/0xc30
> [   46.657004]  [<ffffffff8109eccc>] ? finish_task_switch+0x7c/0x120
> [   46.657004]  [<ffffffff816dad58>] ? retint_swapgs+0x13/0x1b
> [   46.657004]  [<ffffffff8106d139>] do_group_exit+0x49/0xc0
> [   46.657004]  [<ffffffff8106d1c4>] sys_exit_group+0x14/0x20
> [   46.657004]  [<ffffffff816e3b19>] system_call_fastpath+0x16/0x1b
> [   46.657004] ---[ end trace 4468c44e2156e7d1 ]---
> [   46.657004] Mapped at:
> [   46.657004]  [<ffffffff813663d1>] debug_dma_map_page+0x91/0x140
> [   46.657004]  [<ffffffffa030e8eb>] e100_xmit_prepare+0x12b/0x1c0
> [e100]
> [   46.657004]  [<ffffffffa030c924>] e100_exec_cb+0x84/0x140 [e100]
> [   46.657004]  [<ffffffffa030e56a>] e100_xmit_frame+0x3a/0x190 [e100]
> [   46.657004]  [<ffffffff8159ee89>] dev_hard_start_xmit+0x259/0x6c0
>=20
> Easy fix, modify the cb paramter to e100_exec_cb to return an error,
> and do the
> dma_mapping_error check in the obvious place
>=20
> This was reported previously here:
> http://article.gmane.org/gmane.linux.network/257893
>=20
> But nobody stepped up and fixed it.
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Michal Jaegermann <michal@harddata.com>
> CC: Josh Boyer <jwboyer@redhat.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: e1000-devel@lists.sourceforge.net
> ---
>  drivers/net/ethernet/intel/e100.c | 36
> +++++++++++++++++++++++++-----------
>  1 file changed, 25 insertions(+), 11 deletions(-)=20

Thanks Neil, I have added it to my queue.

--=-gHaNfUk9vSTsB92/Lfkp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRXJtrAAoJEOVv75VaS+3OdqcQAIORydvA00O8RkMLLOrVICsj
QKLTGrYiFJsHhkf7wMS9ChAZ6G8UVh1JzosLXlqzM8uBc42KUsosKwIpeM/v3kcT
XRU7sdW63Ow+nZE2oA7xwqf+SKE0g48+4dIXnc15DcQ0DiyeQr0Ce3K5XPLU/MrN
YPxIDPM0kuexGmdbqhC7c9MXD7T9S9J7QBmAqbECfb6Wdo3SZ8c9zohYkWXP9LJh
OOmJOX4DgV5Ojiz8EHdlMIc2ohgR2EWwoWN7ss9lNPQI+a/l5Pj4qtSQ9JN4z6un
RzzzQe5/rTf50dP3W39iVqEcfKCccUE+wsXTuJ0LohC40ywVMYlNMvTb4wWIMLvx
9Srwx30qgu5BJddtM1IGNLMzKYW4DpUt8/WvsgLDOKFzrJ6dgc+9ZAZ8KWi/iwkA
YjSQk8vN3C50c3aH2HSmlGbVC0hXoWCSFLE1teaccCQ1cjFFGas3xEpNV9s+0Mp/
3uzoVEL75JAcUV7srmyZDDhqaH+cbPqlOZeZzdXpnkEvkkLG4uLt9V32S+JV4+p+
S/XdF6fchNLzjdOUeUKQYwi7YEd69piJQtN1Iq/Uh7NYSyfZdfSkdtgL2p8n6qYa
HMN1snTXH8SFehMdRgZ2ETQ180GoG9OeX7o6Xhrx/s6RgZm/a3/0ZtFkB8GB3N+7
ilKL85h61s2/6Hm2KBW+
=wBTT
-----END PGP SIGNATURE-----

--=-gHaNfUk9vSTsB92/Lfkp--
