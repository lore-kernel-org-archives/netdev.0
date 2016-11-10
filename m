From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [v16, 0/7] Fix eSDHC host version register bug
Date: Thu, 10 Nov 2016 10:26:04 +0100
Message-ID: <CAMuHMdVH0-3qbZiOHnSY8BtWaFESC6poyD-Z6H-wfaSvyd4k+g@mail.gmail.com>
References: <1478661252-42439-1-git-send-email-yangbo.lu@nxp.com> <CAPDyKFrcAN_pqgtGaUanfB2zh97zGcL23m5VDtJ3g==NJeRrfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yangbo Lu <yangbo.lu@nxp.com>,
        linux-mmc <linux-mmc@vger.kernel.org>,
        Scott Wood <oss@buserror.net>, Arnd Bergmann <arnd@arndb.de>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-clk <linux-clk@vger.kernel.org>,
        iommu@lists.linux-foundation.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Rob Herring <robh+dt@kernel.org>,
        Russell King <linux@arm.linux.org.uk>,
        Jochen Friedrich <jochen@scram.de>,
        Joerg Roedel <joro@8bytes.org>,
        Claudiu Ma
To: Ulf Hansson <ulf.hansson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPDyKFrcAN_pqgtGaUanfB2zh97zGcL23m5VDtJ3g==NJeRrfA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ulf,

On Wed, Nov 9, 2016 at 7:27 PM, Ulf Hansson <ulf.hansson@linaro.org> wrote:
> On 9 November 2016 at 04:14, Yangbo Lu <yangbo.lu@nxp.com> wrote:
>> This patchset is used to fix a host version register bug in the T4240-R1.0-R2.0
>> eSDHC controller. To match the SoC version and revision, 15 previous version
>> patchsets had tried many methods but all of them were rejected by reviewers.
>> Such as
>>         - dts compatible method
>>         - syscon method
>>         - ifdef PPC method
>>         - GUTS driver getting SVR method
>> Anrd suggested a soc_device_match method in v10, and this is the only available
>> method left now. This v11 patchset introduces the soc_device_match interface in
>> soc driver.
>>
>> The first four patches of Yangbo are to add the GUTS driver. This is used to
>> register a soc device which contain soc version and revision information.
>> The other three patches introduce the soc_device_match method in soc driver
>> and apply it on esdhc driver to fix this bug.
>>
>> ---
>> Changes for v15:
>>         - Dropped patch 'dt: bindings: update Freescale DCFG compatible'
>>           since the work had been done by below patch on ShawnGuo's linux tree.
>>           'dt-bindings: fsl: add LS1043A/LS1046A/LS2080A compatible for SCFG
>>            and DCFG'
>>         - Fixed error code issue in guts driver
>> Changes for v16:
>>         - Dropped patch 'powerpc/fsl: move mpc85xx.h to include/linux/fsl'
>>         - Added a bug-fix patch from Geert
>> ---
>>
>> Arnd Bergmann (1):
>>   base: soc: introduce soc_device_match() interface
>>
>> Geert Uytterhoeven (1):
>>   base: soc: Check for NULL SoC device attributes

> Thanks, applied on my mmc tree for next!

Oops, the above two commits (plus two more enhancements) are also a dependency
for Samsung and Renesas. Hence the plan was to use an immutable branch for
that...

Ulf, would it still be possible to replace these two commits in mmc/next:

    8b82c17a8ae533d6 base: soc: introduce soc_device_match() interface
    6fa350172b098f0f base: soc: Check for NULL SoC device attributes

by a merge of the immutable branch I've just created?
Cfr, the other thread  "[PATCH v2 0/7] soc: renesas: Identify SoC and register
with the SoC bus".

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
