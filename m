From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] igb: Allow extra 4 bytes on RX for vlan tags.
Date: Thu, 17 Feb 2011 03:04:32 -0800
Message-ID: <AANLkTinsWRAJ2bepa1NjQ4f0Wz46DaxWO6f_nEbmBAB0@mail.gmail.com>
References: <1297375149-18458-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:33212 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754877Ab1BQLEd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 06:04:33 -0500
Received: by qwa26 with SMTP id 26so2256858qwa.19
        for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 03:04:32 -0800 (PST)
In-Reply-To: <1297375149-18458-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 10, 2011 at 13:59,  <greearb@candelatech.com> wrote:
> From: Ben Greear <greearb@candelatech.com>
>
> This allows the NIC to receive 1518 byte (not counting
> FCS) packets when MTU is 1500, thus allowing 1500 MTU
> VLAN frames to be received. =C2=A0Please note that no VLANs
> were actually configured on the NIC...it was just acting
> as pass-through device.
>
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 58c665b... 30c9cc6... M =C2=A0drivers/net/igb/igb_main=
=2Ec
> =C2=A0drivers/net/igb/igb_main.c | =C2=A0 =C2=A05 +++--
> =C2=A01 files changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index 58c665b..30c9cc6 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -2281,7 +2281,8 @@ static int __devinit igb_sw_init(struct igb_ada=
pter *adapter)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->rx_itr_setting =3D IGB_DEFAULT_IT=
R;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->tx_itr_setting =3D IGB_DEFAULT_IT=
R;
>
> - =C2=A0 =C2=A0 =C2=A0 adapter->max_frame_size =3D netdev->mtu + ETH_=
HLEN + ETH_FCS_LEN;
> + =C2=A0 =C2=A0 =C2=A0 adapter->max_frame_size =3D (netdev->mtu + ETH=
_HLEN + ETH_FCS_LEN
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0+ VLAN_HLEN);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->min_frame_size =3D ETH_ZLEN + ETH=
_FCS_LEN;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_init(&adapter->stats64_lock);
> @@ -4303,7 +4304,7 @@ static int igb_change_mtu(struct net_device *ne=
tdev, int new_mtu)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct igb_adapter *adapter =3D netdev_pri=
v(netdev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pci_dev *pdev =3D adapter->pdev;
> - =C2=A0 =C2=A0 =C2=A0 int max_frame =3D new_mtu + ETH_HLEN + ETH_FCS=
_LEN;
> + =C2=A0 =C2=A0 =C2=A0 int max_frame =3D new_mtu + ETH_HLEN + ETH_FCS=
_LEN + VLAN_HLEN;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 rx_buffer_len, i;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((new_mtu < 68) || (max_frame > MAX_JUM=
BO_FRAME_SIZE)) {

While testing this patch, validation found that the patch reduces the
maximum mtu size
by 4 bytes (reduces it from 9216 to 9212).  This is not a desired side
effect of this patch.

Thoughts?

--=20
Cheers,
Jeff
