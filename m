From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: linux <=4.9.5, 4.10-rc7 ok, 4.9.6 - 4.9.8 nok with realtek wlan,
 atom
Date: Thu, 9 Feb 2017 13:43:21 -0600
Message-ID: <20170209194321.GC11905@bhelgaas-glaptop.roam.corp.google.com>
References: <CAJs9aZ9FqU-NCj2egBp6J06uD_Qp3Lje=mSSVbV4vNcYGKdumA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@vger.kernel.org,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: rupert THURNER <rupert.thurner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:54182 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753702AbdBITvy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 14:51:54 -0500
Content-Disposition: inline
In-Reply-To: <CAJs9aZ9FqU-NCj2egBp6J06uD_Qp3Lje=mSSVbV4vNcYGKdumA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[+cc rtl8192ce folks in case they've seen this]

On Thu, Feb 09, 2017 at 03:45:01PM +0100, rupert THURNER wrote:
> hi,
> 
> not technical expert enough, i just wanted to give a short user
> feedback. for realtek wlan on atom, kernels up to 4.9.5 are ok, and
> kernel 4.10.0-rc7-g926af6273fc6 (arch linux-git version numbering) as
> well. kernels 4.9.6, 4.9.7, and 4.9.8 fail, i.e. connection to a WLAN
> hotspot is possible then drops, or connecting to wlan fails
> alltogether.

Thanks very much for your report, and sorry for the inconvenience.

v4.10-rc7 works, so I guess we don't need to worry about fixing v4.10.

But the stable kernels v4.9.6, v4.9.7, and v4.9.8 are broken, so we
need to figure out why and make sure we fix the v4.9 stable series.

I can't tell yet whether this is PCI-related or not.  If it is,
4922a6a5cfa7 ("PCI: Enumerate switches below PCI-to-PCIe bridges")
appeared in v4.9.6, and there is a known issue with that.  The issue
should be fixed by 610c2b7ff8f6 ("PCI/ASPM: Handle PCI-to-PCIe bridges
as roots of PCIe hierarchies"), which appeared in v4.9.9, so I guess
the first thing to do would be to test v4.9.9.

If it's not fixed in v4.9.9, can you share the complete dmesg log
(output of "dmesg" command) and "lspci -vv" output for v4.9.5 (last
known working version) and v4.9.6 (first known broken version)?  On
v4.9.6, collect the dmesg output after the failure occurs.

> 24: PCI 300.0: 0282 WLAN controller
>   [Created at pci.366]
>   Model: "Realtek RTL8188CE 802.11b/g/n WiFi Adapter"
>   Device: pci 0x8176 "RTL8188CE 802.11b/g/n WiFi Adapter"
>   Revision: 0x01
>   Driver: "rtl8192ce"
>   Driver Modules: "rtl8192ce"
>   Device File: wlp3s0
>   Features: WLAN
