From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [V4 PATCH 3/6] pci: Generic function for setting up PCI device
 DMA coherency
Date: Wed, 20 May 2015 21:46:45 +0100
Message-ID: <20150520204645.GX2067@n2100.arm.linux.org.uk>
References: <1431724994-21601-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <3954735.qeaTp8qOcM@vostro.rjw.lan>
 <20150520092415.GA25313@e104818-lin.cambridge.arm.com>
 <2072233.lIH4idDurI@wuerfel>
 <20150520093401.GC25313@e104818-lin.cambridge.arm.com>
 <555C7759.3040304@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Arnd Bergmann <arnd@arndb.de>, thomas.lendacky@amd.com,
	herbert@gondor.apana.org.au, al.stone@linaro.org,
	linaro-acpi@lists.linaro.org, netdev@vger.kernel.org,
	will.deacon@arm.com, linux-kernel@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>, davem@davemloft.net,
	linux-acpi@vger.kernel.org, Murali Karicheri <m-karicheri2@ti.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, hanjun.guo@linaro.org,
	msalter@redhat.com, grant.likely@linaro.org, leo.duran@amd.com,
	lenb@kernel.org, bhelgaas@google.com,
	David Woodhouse <dwmw2@infradead.org>,
	linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org
To: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <555C7759.3040304@amd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 20, 2015 at 07:00:25AM -0500, Suravee Suthikulanit wrote:
> On 5/20/2015 4:34 AM, Catalin Marinas wrote:
> >We have a dummy of_dma_configure() already when !CONFIG_OF, otherwise
> >we would need #ifndef here. I already replied, I think for other
> >architectures we need this check to avoid a useless host->of_node test.
> 
> It seems that there are several places that have similar check. Would it be
> good to convert this into a macro? Something like:
> 
> #define OF_NODE_ENABLED(dev)	(IS_ENABLED(CONFIG_OF) && dev->of_node)

This /could/ be a useful compile-time optimisation: when CONFIG_OF is
disabled, dev->of_node exists but will always be NULL - but the
compiler doesn't know this.  Your suggestion above would tell the
compiler that when CONFIG_OF is disabled, OF_NODE_ENABLED() will
evaluate to a constant false, which means it can eliminate code.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
