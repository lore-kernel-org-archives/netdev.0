From: Jon Hunter <jonathanh@nvidia.com>
Subject: Re: [PATCH v3 3/5] net: asix: Fix AX88772x resume failures
Date: Tue, 29 Nov 2016 10:51:20 +0000
Message-ID: <a0815b0b-2d28-cb98-3ceb-817b74e25f49@nvidia.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
 <c708db3f1e006df543284cf5215b965ce4fc44ec.1472155176.git-series.robert.foss@collabora.com>
 <77fa76d6-ef63-47db-a316-93b3a0c0705b@nvidia.com>
 <00e501d23e54$337d4b70$9a77e250$@asix.com.tw>
 <f0d21edc-060b-bd9b-fced-faf1f51e8467@nvidia.com>
 <010d01d23e5b$d8993130$89cb9390$@asix.com.tw>
 <1fff2d2a-7bbe-298c-3d27-7dc44df08675@nvidia.com>
 <6aebd7f5-188a-f6b0-7eb0-75b764e069d3@nvidia.com>
 <014301d24a1e$34513fe0$9cf3bfa0$@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: <allan@asix.com.tw>, <robert.foss@collabora.com>,
        <freddy@asix.com.tw>, <Dean_Jenkins@mentor.com>,
        <Mark_Craske@mentor.com>, <davem@davemloft.net>,
        <ivecera@redhat.com>, <john.stultz@linaro.org>,
        <vpalatin@chromium.org>, <stephen@networkplumber.org>,
        <grundler@chromium.org>, <changchias@gmail.com>, <andrew@lunn.ch>,
        <tremyfr@gmail.com>, <colin.king@canonical.com>,
        <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <vpalatin@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate15.nvidia.com ([216.228.121.64]:9347 "EHLO
        hqemgate15.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756034AbcK2Kvh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 05:51:37 -0500
In-Reply-To: <014301d24a1e$34513fe0$9cf3bfa0$@asix.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Allan,

On 29/11/16 08:54, ASIX_Allan [Office] wrote:
> Dear Jon ,
> 
> We can reproduce your issue on x86 Linux kernel 4.9.0-rc system in our site
> and modified the following code can fix this issue. Please let us know if
> you still have problems. Thanks a lot.
> 
> static void ax88772_suspend(struct usbnet *dev)
> {
>         struct asix_common_private *priv = dev->driver_priv;
>         u16 medium;
> 
>         /* Stop MAC operation */
> -       medium = asix_read_medium_status(dev, 0);
> +      medium = asix_read_medium_status(dev, 1);
>         medium &= ~AX_MEDIUM_RE;
> -       asix_write_medium_mode(dev, medium, 0);
> +      asix_write_medium_mode(dev, medium, 1);
> 
>         netdev_dbg(dev->net, "ax88772_suspend: medium=0x%04x\n",
> -                  asix_read_medium_status(dev, 0));
> +                 asix_read_medium_status(dev, 1));
> 
>         /* Preserve BMCR for restoring */
>         priv->presvd_phy_bmcr =
>                 asix_mdio_read_nopm(dev->net, dev->mii.phy_id, MII_BMCR);
> 
>         /* Preserve ANAR for restoring */
>         priv->presvd_phy_advertise =
>                 asix_mdio_read_nopm(dev->net, dev->mii.phy_id,
> MII_ADVERTISE);
> } 

I gave this a quick test this morning and I can confirm that with the
above change I no longer see the error messages. So feel free to add my ...

Tested-by: Jon Hunter <jonathanh@nvidia.com>

Cheers
Jon

-- 
nvpublic
