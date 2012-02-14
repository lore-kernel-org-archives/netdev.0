From: Sameer Nanda <snanda@chromium.org>
Subject: Re: [PATCH 1/2] r8169: Enable WOL from Magic Packet by default
Date: Tue, 14 Feb 2012 10:33:21 -0800
Message-ID: <CANMivWZ9OsEVpqUHCG=GYz82rv6f31Ppkh_-f7+Uf_BKU4rwgA@mail.gmail.com>
References: <1329244079-27842-1-git-send-email-snanda@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	Sameer Nanda <snanda@chromium.org>
To: romieu@fr.zoreil.com, jw@sisk.pl, hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:41497 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487Ab2BNSdm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 13:33:42 -0500
Received: by qafk1 with SMTP id k1so448941qaf.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 10:33:41 -0800 (PST)
In-Reply-To: <1329244079-27842-1-git-send-email-snanda@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ixed Francois Romieu email address.

On Tue, Feb 14, 2012 at 10:27 AM, Sameer Nanda <snanda@chromium.org> wr=
ote:
>
> Set the WOL config registers to only enable WOL from magic packet by
> default. Without this change in place, the WOL config register
> settings on warm reboot come up in an inconsistent state since these
> registers don't get reset on a warm reboot.
>
> Signed-off-by: Sameer Nanda <snanda@chromium.org>
> ---
> =C2=A0drivers/net/ethernet/realtek/r8169.c | =C2=A0 11 ++++++-----
> =C2=A01 files changed, 6 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index 7a0c800..a6921b7 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -4073,12 +4073,13 @@ rtl8169_init_one(struct pci_dev *pdev, const =
struct pci_device_id *ent)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tp->txd_version =3D rtl_chip_infos[chipset=
].txd_version;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0RTL_W8(Cfg9346, Cfg9346_Unlock);
> +
> + =C2=A0 =C2=A0 =C2=A0 /* Enable WOL from Magic Packet by default */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0RTL_W8(Config1, RTL_R8(Config1) | PMEnable=
);
> - =C2=A0 =C2=A0 =C2=A0 RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
> - =C2=A0 =C2=A0 =C2=A0 if ((RTL_R8(Config3) & (LinkUp | MagicPacket))=
 !=3D 0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp->features |=3D =
RTL_FEATURE_WOL;
> - =C2=A0 =C2=A0 =C2=A0 if ((RTL_R8(Config5) & (UWF | BWF | MWF)) !=3D=
 0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp->features |=3D =
RTL_FEATURE_WOL;
> + =C2=A0 =C2=A0 =C2=A0 RTL_W8(Config3, MagicPacket);
> + =C2=A0 =C2=A0 =C2=A0 RTL_W8(Config5, PMEStatus);
> + =C2=A0 =C2=A0 =C2=A0 tp->features |=3D RTL_FEATURE_WOL;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tp->features |=3D rtl_try_msi(tp, cfg);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0RTL_W8(Cfg9346, Cfg9346_Lock);
>
> --
> 1.7.7.3
>



--
Sameer
