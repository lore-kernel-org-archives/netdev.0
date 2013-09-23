From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] igb: fix driver reload with VF assigned to
 guest
Date: Mon, 23 Sep 2013 14:10:59 -0700
Message-ID: <1379970659.1906.3.camel@jtkirshe-mobl.jf.intel.com>
References: <1379941611-19605-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gqGEbLZoQZUiO0UseMC9"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	davem@davemloft.net, alexander.h.duyck@intel.com,
	carolyn.wyborny@intel.com, gregory.v.rose@intel.com
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23719 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019Ab3IWVLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 17:11:00 -0400
In-Reply-To: <1379941611-19605-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gqGEbLZoQZUiO0UseMC9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-09-23 at 15:06 +0200, Stefan Assmann wrote:
> commit fa44f2f185f7f9da19d331929bb1b56c1ccd1d93 broke reloading of
> igb, when
> VFs are assigned to a guest, in several ways.
> 1. on module load adapter->vf_data does not get properly allocated,
> resulting in a null pointer exception when accessing adapter->vf_data
> in
> igb_reset() on module reload.
>  modprobe -r igb ; modprobe igb max_vfs=3D7
> [  215.215837] igb 0000:01:00.1: removed PHC on eth1
> [  216.932072] igb 0000:01:00.1: IOV Disabled
> [  216.937038] igb 0000:01:00.0: removed PHC on eth0
> [  217.127032] igb 0000:01:00.0: Cannot deallocate SR-IOV virtual
> functions while they are assigned - VFs will not be deallocated
> [  217.146178] igb: Intel(R) Gigabit Ethernet Network Driver - version
> 5.0.5-k
> [  217.154050] igb: Copyright (c) 2007-2013 Intel Corporation.
> [  217.160688] igb 0000:01:00.0: Enabling SR-IOV VFs using the module
> parameter is deprecated - please use the pci sysfs interface.
> [  217.173703] igb 0000:01:00.0: irq 103 for MSI/MSI-X
> [  217.179227] igb 0000:01:00.0: irq 104 for MSI/MSI-X
> [  217.184735] igb 0000:01:00.0: irq 105 for MSI/MSI-X
> [  217.220082] BUG: unable to handle kernel NULL pointer dereference
> at 0000000000000048
> [  217.228846] IP: [<ffffffffa007c5e5>] igb_reset+0xc5/0x4b0 [igb]
> [  217.235472] PGD 3607ec067 PUD 36170b067 PMD 0
> [  217.240461] Oops: 0002 [#1] SMP
> [  217.244085] Modules linked in: igb(+) igbvf mptsas mptscsih mptbase
> scsi_transport_sas [last unloaded: igb]
> [  217.255040] CPU: 4 PID: 4833 Comm: modprobe Not tainted 3.11.0+ #46
> [...]
> [  217.390007]  [<ffffffffa007fab2>] igb_probe+0x892/0xfd0 [igb]
> [  217.396422]  [<ffffffff81470b3e>] local_pci_probe+0x1e/0x40
> [  217.402641]  [<ffffffff81472029>] pci_device_probe+0xf9/0x110
> [...]
> 2. A follow up issue, pci_enable_sriov() should only be called if no
> VFs were
> still allocated on module unload. Otherwise pci_enable_sriov() gets
> called
> multiple times in a row rendering the NIC unusable until reset.
> 3. simply calling igb_enable_sriov() in igb_probe_vfs() is not enough
> as the
> interrupts need to be re-setup. Switching that to
> igb_pci_enable_sriov().
>=20
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 37
> +++++++++++++------------------
>  1 file changed, 16 insertions(+), 21 deletions(-)

Thanks Stefan! I have added the patch to my queue.

--=-gqGEbLZoQZUiO0UseMC9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSQK5jAAoJEOVv75VaS+3Obp4P/1+2s8Xxh3s7WhTUk6oWgzH4
/+PDnz6GXGwN2pOrFH5D7zbYObTArs6hERD+0YOGKE4i/x4vngPBbequcMitf/zX
Gfec6dWSlZ9ixvTpNSYbuhbRzNUQNA4FJVB9LFBsWIU6ycWZ+KWqsKtLFFTiHNor
xuELmd41bde/NQyTwj51JPUcRR+2XlFor+Yo01qu3r+PntyiUGmtAJJ2VVM71PzX
RPjSZTL1IvSakd2CUUr0lA663d9oGnUh7KaPed+FBxZTfjY/hfFtEPTbpnVh0Md2
0zHF7O0bhYoWtHp3BipAnFIl/tgh0Sv4JfyzhLlhWqmbNpQoTB73T18djrdEr5VV
aAs8rgs9X0udUAZwqaxTYFFpZY5dAM6AsbzcDucUPdyPnouAbMm1BbQUsgJjVM6/
I83XH/ZT0k7+tspOL84xoEvW3fIJtMBhuqpZXZqoqbDW8e/G3WwiuOIzbY/m0aod
nt8uT11XPWLiJMO22U18Xg8fMYjzCdgsnPBfZjHYMTBztSAihtnC6ph3/4HlRUaQ
eyn4JG9URUwasoTJYzJX47NADoloawv/k5q5MC1WNsA1HgxfyWPWFhHP7lT4FbP6
wPNRsEldLO2vgZd0LRc/wLUCy/BNoxdBRHcN5X7AIAo5hJbSLUWpJeeWeA4oXf0E
InvFkvNOhIb2FgWI5jBh
=Z7tC
-----END PGP SIGNATURE-----

--=-gqGEbLZoQZUiO0UseMC9--
