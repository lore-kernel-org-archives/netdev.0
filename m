From: Chris Snook <chris.snook@gmail.com>
Subject: Re: [PATCH 1/2] atl1: fix resume
Date: Thu, 16 Sep 2010 16:13:54 -0400
Message-ID: <AANLkTimAUO0+z8oUpm+LrhY-=7ge9iJd=e8TMfsXeOj0@mail.gmail.com>
References: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com> <1284665387-10289-2-git-send-email-kronos.it@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	jcliburn@gmail.com, jie.yang@atheros.com, stable@kernel.org
To: Luca Tettamanti <kronos.it@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:54842 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309Ab0IPUOR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 16:14:17 -0400
Received: by qwh6 with SMTP id 6so1241644qwh.19
        for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 13:14:16 -0700 (PDT)
In-Reply-To: <1284665387-10289-2-git-send-email-kronos.it@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 16, 2010 at 3:29 PM, Luca Tettamanti <kronos.it@gmail.com> =
wrote:
> adapter->cmb.cmb is initialized when the device is opened and freed w=
hen
> it's closed. Accessing it unconditionally during resume results eithe=
r
> in a crash (NULL pointer dereference, when the interface has not been
> opened yet) or data corruption (when the interface has been used and
> brought down adapter->cmb.cmb points to a deallocated memory area).
>
> Cc: stable@kernel.org
> ---
> =A0drivers/net/atlx/atl1.c | =A0 =A05 +++--
> =A01 files changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
> index 63b9ba0..bbd6e30 100644
> --- a/drivers/net/atlx/atl1.c
> +++ b/drivers/net/atlx/atl1.c
> @@ -2847,10 +2847,11 @@ static int atl1_resume(struct pci_dev *pdev)
> =A0 =A0 =A0 =A0pci_enable_wake(pdev, PCI_D3cold, 0);
>
> =A0 =A0 =A0 =A0atl1_reset_hw(&adapter->hw);
> - =A0 =A0 =A0 adapter->cmb.cmb->int_stats =3D 0;
>
> - =A0 =A0 =A0 if (netif_running(netdev))
> + =A0 =A0 =A0 if (netif_running(netdev)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 adapter->cmb.cmb->int_stats =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atl1_up(adapter);
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0netif_device_attach(netdev);
>
> =A0 =A0 =A0 =A0return 0;
> --
> 1.7.1
>
>

Thanks.  I confirmed that the other atlx drivers (which I have been
reminded I need to finish merging into a single driver) do not have
this bug.

Acked-by: Chris Snook <chris.snook@gmail.com>
