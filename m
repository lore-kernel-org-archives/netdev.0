From: Sathya Perla <sathya.perla@broadcom.com>
Subject: Re: [PATCH net-next] be2net: don't report EVB for older chipsets when
 SR-IOV is disabled
Date: Thu, 11 Feb 2016 10:56:35 +0100
Message-ID: <CAKvpyk1u=59YZLoX9kTpTFm0=bXdyE-LaZpCobZwmWo+wa5RTg@mail.gmail.com>
References: <1455106400-16330-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Ajit Khaparde <ajit.khaparde@broadcom.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
	Somnath Kotur <somnath.kotur@broadcom.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:36271 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbcBKJ4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 04:56:36 -0500
Received: by mail-yw0-f177.google.com with SMTP id q190so35123221ywd.3
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 01:56:36 -0800 (PST)
In-Reply-To: <1455106400-16330-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2016 at 1:13 PM, Ivan Vecera <ivecera@redhat.com> wrote:
>
> The EVB (virtual bridge) functionality should be disabled on older BE3
> and Lancer chips if SR-IOV is disabled in the NIC's BIOS. This setting
> is identified by the zero value of total VFs reported by the card.
> The GET_HSW_CONFIG command cannot be used as it is not supported > by these older chipset's FW.
>
..
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index 9c1fc9d..886fe95 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -4588,6 +4588,8 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>
>         /* BE and Lancer chips support VEB mode only */
>         if (BEx_chip(adapter) || lancer_chip(adapter)) {
> +               if (!pci_sriov_get_totalvfs(adapter->pdev))
> +                       return 0;

Ivan, could you add a one line comment above this check that says "On
BE3/Lancer the VEB is disabled in non-SRIOV profiles". This is to
differentiate this behavior from Skyhawk, where the VEB may be enabled
even in non-SRIOV profiles, like nPAR...

thanks,
-Sathya
