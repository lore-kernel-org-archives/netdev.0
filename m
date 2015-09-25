From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: via/Kconfig: GENERIC_PCI_IOMAP required if PCI not
 selected
Date: Fri, 25 Sep 2015 21:03:52 +0300
Message-ID: <56058C88.3070907@cogentembedded.com>
References: <1443089813-10967-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hans-Christian Egtvedt <egtvedt@samfundet.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443089813-10967-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 9/24/2015 1:16 PM, Sudip Mukherjee wrote:

> The builds of allmodconfig of avr32 is failing with:
>
> drivers/net/ethernet/via/via-rhine.c:1098:2: error: implicit declaration
> of function 'pci_iomap' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/via/via-rhine.c:1119:2: error: implicit declaration
> of function 'pci_iounmap' [-Werror=implicit-function-declaration]
>
> The generic empty pci_iomap and pci_iounmap is used only if CONFIG_PCI
> is not defined and CONFIG_GENERIC_PCI_IOMAP is defined.
>
> Add GENERIC_PCI_IOMAP in the dependency list for VIA_RHINE as we are
> getting build failure when CONFIG_PCI and CONFIG_GENERIC_PCI_IOMAP both
> are not defined.
>
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> ---
>
> Failed build log is at:
> https://travis-ci.org/sudipm-mukherjee/parport/jobs/81127188
>
> An exactly similar patch has been posted earlier and relevant discussion
> is at:
> https://patchwork.ozlabs.org/patch/498722/
>
> I posted a patch to include empty pci_iomap, pci_iounmap in avr32. That
> discussion is at:
> https://lkml.org/lkml/2015/9/19/100
>
>   drivers/net/ethernet/via/Kconfig | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/via/Kconfig b/drivers/net/ethernet/via/Kconfig
> index 2f1264b..17831e5 100644
> --- a/drivers/net/ethernet/via/Kconfig
> +++ b/drivers/net/ethernet/via/Kconfig
> @@ -17,7 +17,7 @@ if NET_VENDOR_VIA
>
>   config VIA_RHINE
>   	tristate "VIA Rhine support"
> -	depends on (PCI || OF_IRQ)
> +	depends on (PCI || (OF_IRQ && GENERIC_PCI_IOMAP))

   Could you remove outer braces, while at it?

[...]

MBR, Sergei
