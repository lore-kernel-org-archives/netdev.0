From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: net: thunderx: Buffer overwrite on bgx_probe
Date: Thu, 3 Aug 2017 13:04:01 +0530
Message-ID: <CA+sq2CeQB0OSNadQNd5oofmmsNsHtinShe2OZhGBGk6sU5xYkQ@mail.gmail.com>
References: <86a1b4d9-db67-4380-13c9-f759d2e05ed9@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Sunil Goutham <sgoutham@cavium.com>, ldv-project@linuxtesting.org,
        Linux Netdev List <netdev@vger.kernel.org>,
        Robert Richter <rric@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        LAKML <linux-arm-kernel@lists.infradead.org>
To: Anton Vasilyev <vasilyev@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <86a1b4d9-db67-4380-13c9-f759d2e05ed9@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 2, 2017 at 10:29 PM, Anton Vasilyev <vasilyev@ispras.ru> wrote:
> Hello.
>
> While searching for memory errors in Linux kernel I've come across
> drivers/net/ethernet/cavium/thunder/thunder_bgx.ko module.
>
> I've found buffer overwrite at bgx_probe():
> Consider device PCI_SUBSYS_DEVID_83XX_BGX.
> max_bgx_per_node is set to 4 by set_max_bgx_per_node().
> Then on branch:
>     pci_read_config_word(pdev, PCI_DEVICE_ID, &sdevid);
>     if (sdevid != PCI_DEVICE_ID_THUNDER_RGX) {
>         bgx->bgx_id = (pci_resource_start(pdev,
>             PCI_CFG_REG_BAR_NUM) >> 24) & BGX_ID_MASK;
>         bgx->bgx_id += nic_get_node_id(pdev) * max_bgx_per_node;
>
> bgx->bgx_id could achieve value 3 + 3 * 4 = 15,

No, this will never be the case, the maximum no of NUMA nodes supported
on these platforms is 2, so the bgx_id will never go beyond 7.
And the platform 83XX taken as an example deosn't support NUMA, it's only
88XX which supports NUMA  and maximum no of BGX supported on that is only 2.


> which lead to buffer overwrite on
>         bgx_vnic[bgx->bgx_id] = bgx;
>
> Question: is it enough for fix to change bgx_vnic's size?
>
> Found by Linux Driver Verification project (linuxtesting.org).
>
> --
> Anton Vasilyev
> Linux Verification Center, ISPRAS
> web: http://linuxtesting.org
> e-mail: vasilyev@ispras.ru
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

Thanks,
Sunil.
