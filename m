From: Jon Mason <jdmason@kudzu.us>
Subject: Re: [PATCH 29/52] net: neterion: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 11:05:17 -0700
Message-ID: <CAPoiz9xLT=p0ws3CyeiBnANuujheJHzXiC1b8Xg_rFJ5AXuW3w@mail.gmail.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
	<006701ceaec3$dce53e30$96afba90$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:36508 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351Ab3IKSFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 14:05:19 -0400
Received: by mail-lb0-f169.google.com with SMTP id z5so7764474lbh.14
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 11:05:18 -0700 (PDT)
In-Reply-To: <006701ceaec3$dce53e30$96afba90$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 11, 2013 at 12:52 AM, Jingoo Han <jg1.han@samsung.com> wrote:
> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
>
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Looks sane to me.
Acked-by: Jon Mason <jdmason@kudzu.us>

> ---
>  drivers/net/ethernet/neterion/s2io.c           |    2 --
>  drivers/net/ethernet/neterion/vxge/vxge-main.c |    2 --
>  2 files changed, 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
> index 51b0094..9eeddbd 100644
> --- a/drivers/net/ethernet/neterion/s2io.c
> +++ b/drivers/net/ethernet/neterion/s2io.c
> @@ -8185,7 +8185,6 @@ mem_alloc_failed:
>         free_shared_mem(sp);
>         pci_disable_device(pdev);
>         pci_release_regions(pdev);
> -       pci_set_drvdata(pdev, NULL);
>         free_netdev(dev);
>
>         return ret;
> @@ -8221,7 +8220,6 @@ static void s2io_rem_nic(struct pci_dev *pdev)
>         iounmap(sp->bar0);
>         iounmap(sp->bar1);
>         pci_release_regions(pdev);
> -       pci_set_drvdata(pdev, NULL);
>         free_netdev(dev);
>         pci_disable_device(pdev);
>  }
> diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
> index 5a20eaf..8614eeb 100644
> --- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
> +++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
> @@ -4739,7 +4739,6 @@ _exit6:
>  _exit5:
>         vxge_device_unregister(hldev);
>  _exit4:
> -       pci_set_drvdata(pdev, NULL);
>         vxge_hw_device_terminate(hldev);
>         pci_disable_sriov(pdev);
>  _exit3:
> @@ -4782,7 +4781,6 @@ static void vxge_remove(struct pci_dev *pdev)
>                 vxge_free_mac_add_list(&vdev->vpaths[i]);
>
>         vxge_device_unregister(hldev);
> -       pci_set_drvdata(pdev, NULL);
>         /* Do not call pci_disable_sriov here, as it will break child devices */
>         vxge_hw_device_terminate(hldev);
>         iounmap(vdev->bar0);
> --
> 1.7.10.4
>
>
