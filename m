From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-acpi] [V4 PATCH 3/6] pci: Generic function for setting up PCI device DMA coherency
Date: Wed, 20 May 2015 14:02:40 +0200
Message-ID: <2673003.mTFjFBS7Ob@wuerfel>
References: <1431724994-21601-1-git-send-email-Suravee.Suthikulpanit@amd.com> <20150520093401.GC25313@e104818-lin.cambridge.arm.com> <555C7759.3040304@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	will.deacon@arm.com, linux-kernel@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>, davem@davemloft.net,
	linux-acpi@vger.kernel.org, Murali Karicheri <m-karicheri2@ti.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, lenb@kernel.org,
	bhelgaas@google.com, David Woodhouse <dwmw2@infradead.org>,
	linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org
To: linaro-acpi@lists.linaro.org
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <555C7759.3040304@amd.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 20 May 2015 07:00:25 Suravee Suthikulanit wrote:
> It seems that there are several places that have similar check. Would it 
> be good to convert this into a macro? Something like:
> 
> #define OF_NODE_ENABLED(dev)    (IS_ENABLED(CONFIG_OF) && dev->of_node)
> 
> Thanks all for the review feedback.
> 

Better make that an inline function that returns the node:

struct device_node *dev_of_node(struct device *)
{
	if (IS_ENABLED(CONFIG_OF))
		return dev->of_node;

	return NULL;
}

	Arnd
