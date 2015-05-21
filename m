From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [Linaro-acpi] [V4 PATCH 1/6] ACPI / scan: Parse _CCA and setup
 device coherency
Date: Thu, 21 May 2015 14:01:16 +0100
Message-ID: <20150521130116.GJ29424@e104818-lin.cambridge.arm.com>
References: <1431724994-21601-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <20150520100122.GD25313@e104818-lin.cambridge.arm.com>
 <555C7563.6080409@amd.com>
 <5074701.G8z7gpKvin@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linaro-acpi@lists.linaro.org, rjw@rjwysocki.net,
	herbert@gondor.apana.org.au, will.deacon@arm.com,
	linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	Suravee Suthikulanit <suravee.suthikulpanit@amd.com>,
	netdev@vger.kernel.org, bhelgaas@google.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, lenb@kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5074701.G8z7gpKvin@wuerfel>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 20, 2015 at 02:04:02PM +0200, Arnd Bergmann wrote:
> On Wednesday 20 May 2015 06:52:03 Suravee Suthikulanit wrote:
> > On 5/20/2015 5:01 AM, Catalin Marinas wrote:
> > > On Fri, May 15, 2015 at 04:23:09PM -0500, Suravee Suthikulpanit wrote:
> > >> +static inline bool acpi_dma_is_supported(struct acpi_device *adev)
> > >> +{
> > >> +    /**
> > >> +     * Currently, we mainly support _CCA=1 (i.e. is_coherent=1)
> > >> +     * This should be equivalent to specifyig dma-coherent for
> > >> +     * a device in OF.
> > >> +     *
> > >> +     * For the case when _CCA=0 (i.e. is_coherent=0 && cca_seen=1),
> > >> +     * There are two approaches:
> > >> +     * 1. Do not support and disable DMA.
> > >> +     * 2. Support but rely on arch-specific cache maintenance for
> > >> +     * non-coherence DMA operations. ARM64 is one example.
> > >> +     *
> > >> +     * For the case when _CCA is missing (i.e. cca_seen=0) but
> > >> +     * platform specifies ACPI_CCA_REQUIRED, we do not support DMA,
> > >> +     * and fallback to arch-specific default handling.
> > >> +     *
> > >> +     * See acpi_init_coherency() for more info.
> > >> +     */
> > >> +    return adev && (adev->flags.is_coherent ||
> > >> +                    (adev->flags.cca_seen && IS_ENABLED(CONFIG_ARM64)));
> > >> +}
> > >
> > > I don't particularly like the check for CONFIG_ARM64 here but I
> > > understand why it was added (I had the wrong impression that x86 can
> > > cope with _CCA = 0).
> > >
> > > Alternatively, we could leave it out (together with cca_seen) until
> > > someone comes forward with a real use-case for _CCA = 0 on arm64. One
> > > platform I'm aware of is Juno but even though it boot with ACPI, I
> > > wouldn't call it a server platform.
> > 
> > Ok. That seems to be what Arnd would prefer as well.  Let's just leave 
> > the support for _CCA=0 out until it is needed then.
> 
> Yes, that would be best (as I said repeatedly ;-) )

I'm sure it won't be long before someone asks for this feature ;).

-- 
Catalin
