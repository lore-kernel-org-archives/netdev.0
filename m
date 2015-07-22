From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: via/Kconfig: GENERIC_PCI_IOMAP required if PCI
 not selected
Date: Wed, 22 Jul 2015 11:08:36 -0700 (PDT)
Message-ID: <20150722.110836.422018977846427052.davem@davemloft.net>
References: <1437582854-3320-1-git-send-email-borneo.antonio@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, alchark@gmail.com
To: borneo.antonio@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1437582854-3320-1-git-send-email-borneo.antonio@gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Antonio Borneo <borneo.antonio@gmail.com>
Date: Thu, 23 Jul 2015 00:34:14 +0800

> -	depends on (PCI || OF_IRQ)
> +	depends on (PCI || (OF_IRQ && GENERIC_PCI_IOMAP))

Having GENERIC_PCI_IOMAP withut PCI makes absolutely no sense to me.

I can't see why a platform would provide GENERIC_PCI_IOMAP when it
does not have PCI enabled.

You need to explain this.

When PCI is not enabled, you should not be using any interface
pci_*() whatsoever.  Especially such a core interface as pci_iomap().

ALTERNATIVELY, NOP versions of pci_iomap() and friends should be
provided when PCI is disabled, which just return errors and
non-success statuses.
