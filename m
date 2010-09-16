From: Chris Snook <chris.snook@gmail.com>
Subject: Re: [PATCH 2/2] atl1: zero out CMB and SBM in atl1_free_ring_resources
Date: Thu, 16 Sep 2010 16:15:36 -0400
Message-ID: <AANLkTi=BfJngfELYhJqhpSbaPsKy7uAPeLmHdBGUX6mZ@mail.gmail.com>
References: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com> <1284665387-10289-3-git-send-email-kronos.it@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, jie.yang@atheros.com
To: Luca Tettamanti <kronos.it@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:47231 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454Ab0IPUP5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 16:15:57 -0400
Received: by qwh6 with SMTP id 6so1242825qwh.19
        for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 13:15:56 -0700 (PDT)
In-Reply-To: <1284665387-10289-3-git-send-email-kronos.it@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 16, 2010 at 3:29 PM, Luca Tettamanti <kronos.it@gmail.com> =
wrote:
> They are allocated in atl1_setup_ring_resources, zero out the pointer=
s
> in atl1_free_ring_resources (like the other resources).
> ---
> =A0drivers/net/atlx/atl1.c | =A0 =A06 ++++++
> =A01 files changed, 6 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
> index bbd6e30..c73be28 100644
> --- a/drivers/net/atlx/atl1.c
> +++ b/drivers/net/atlx/atl1.c
> @@ -1251,6 +1251,12 @@ static void atl1_free_ring_resources(struct at=
l1_adapter *adapter)
>
> =A0 =A0 =A0 =A0rrd_ring->desc =3D NULL;
> =A0 =A0 =A0 =A0rrd_ring->dma =3D 0;
> +
> + =A0 =A0 =A0 adapter->cmb.dma =3D 0;
> + =A0 =A0 =A0 adapter->cmb.cmb =3D NULL;
> +
> + =A0 =A0 =A0 adapter->smb.dma =3D 0;
> + =A0 =A0 =A0 adapter->smb.smb =3D NULL;
> =A0}
>
> =A0static void atl1_setup_mac_ctrl(struct atl1_adapter *adapter)
> --
> 1.7.1
>
>

Acked-by: Chris Snook <chris.snook@gmail.com>
