From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: BRCMFMAC OOB interrupt problem
Date: Thu, 1 Jun 2017 11:38:28 +0200
Message-ID: <4c82d08f-60cc-9ef6-4598-81a616782d11@broadcom.com>
References: <BY2PR07MB15534619EB5D533B633CDAF5CEF60@BY2PR07MB1553.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "brcm80211-dev-list.pdl@broadcom.com"
        <brcm80211-dev-list.pdl@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Hegr, Jiri" <Jiri.Hegr2@Honeywell.com>,
        "franky.lin@broadcom.com" <franky.lin@broadcom.com>,
        "hante.meuleman@broadcom.com" <hante.meuleman@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2PR07MB15534619EB5D533B633CDAF5CEF60@BY2PR07MB1553.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01-06-17 09:44, Hegr, Jiri wrote:
> Dears,
> We use small WiFi evaluation board WM-BN-BM-04_EVB_V1.2 with BCM43362 chip (Broadcom).
> This board is connected to OMAP-L138 via SDIO interface with Linux 4.9.10 containing WiFi driver brcmfmac.
> Our problem is in OOB interrupt. The driver (and the WiFi chip) works fine if the interrupt is not set in a device tree (SDIO interface is used instead).
> But if the host-wake interrupt is used, the initialization phase does not pass. We are sure that the OOB interrupt is triggered. We found out that it waits for a control frame (probably) but it gets some event frame only. After about 2.5 seconds the timeout occurs and the initialization fails.
> Could you help us to solve the problem?
> There is our device tree settings and terminal output bellow (the "DBG" lines are our own).
> 
> There is also problem with WARN_ON(nents > sdiodev->max_segment_count); in bcmsdh.c file, but it seems that it does not influence the driver work because the problem occurs without OOB interrupt setting also and everything works fine.
> 
> Regards,
> 
> Jiri Hegr
> 
> mmc1: mmc@21b000 {
>      #address-cells = <1>;
>      #size-cells = <0>;
>      max-frequency = <25000000>;
>      bus-width = <4>;
>      pinctrl-names = "default";
>      pinctrl-0 = <&mmc1_pins>;
>      status = "okay";
>      non-removable;
> 
>      brcmf: bcrmf@1 {
> reg = <1>;
> compatible = "brcm,bcm4329-fmac";
> interrupt-parent = <&gpio>;
> interrupts = <95 0x02>;
> interrupt-names = "host-wake";
>      };
> };
> 
> [   24.314527] brcmfmac: *** DBG: starting datawork worker thread...
> [   24.354778] brcmfmac: *** DBG: brcmf_sdio_readframes...
> [   24.360088] brcmfmac: *** DBG: rd->len check: 0
> [   24.404232] brcmfmac: *** DBG: rd->channel check: 1
> [   24.435047] brcmfmac: *** DBG: rd->len check: 0
> [   24.454977] brcmfmac: *** DBG: brcmf_sdio_readframes - loop break
> [   27.013900] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
> [   27.019813] brcmfmac: brcmf_c_preinit_dcmds: Retreiving cur_etheraddr failed, -110
> [   27.031282] brcmfmac: brcmf_bus_start: failed: -110
> [   27.046164] brcmfmac: brcmf_sdio_firmware_callback: dongle is not responding

Can you build the driver with CONFIG_BRCMDBG and load the driver with
debugging:

$ sudo insmod brcmfmac.ko debug=0x31516

Regards,
Arend

>                                           Honeywell  *
> Jiri Hegr - R&D Scientist III.
> 
> Honeywell International s.r.o. - Aerospace Advanced Techonologies
> V Parku 2325/16
> Praha 148 00, Czech Republic
> Office: Turanka 100
> 627 00 Brno, Czech Republic
> 
> Tel:         +420 532 115 564
> E-mail:    jiri.hegr2@honeywell.com<mailto:jiri.hegr2@honeywell.com>
> 
> 
