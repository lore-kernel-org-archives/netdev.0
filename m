From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH -next] PCI: fix tlan build when CONFIG_PCI is not
 enabled
Date: Wed, 16 Feb 2011 11:46:19 -0800
Message-ID: <20110216114619.7fbfb3cf@jbarnes-desktop>
References: <20110214181137.ee8d4c08.sfr@canb.auug.org.au>
	<20110214122750.e1e03bc8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-pci@vger.kernel.org,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, Sakari Ailus <sakari.ailus@iki.fi>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110214122750.e1e03bc8.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Feb 2011 12:27:50 -0800
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> When CONFIG_PCI is not enabled, tlan.c has a build error:
> drivers/net/tlan.c:503: error: implicit declaration of function 'pci_wake_from_d3'
> 
> so add an inline function stub for this function to pci.h when
> PCI is not enabled, similar to other stubbed PCI functions.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: Sakari Ailus <sakari.ailus@iki.fi>
> ---
>  include/linux/pci.h |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> --- linux-next-20110214.orig/include/linux/pci.h
> +++ linux-next-20110214/include/linux/pci.h
> @@ -1191,6 +1191,11 @@ static inline int pci_set_power_state(st
>  	return 0;
>  }
>  
> +static inline int pci_wake_from_d3(struct pci_dev *dev, bool enable)
> +{
> +	return 0;
> +}
> +
>  static inline pci_power_t pci_choose_state(struct pci_dev *dev,
>  					   pm_message_t state)
>  {
> 

Applied to linux-next, thanks guys.

-- 
Jesse Barnes, Intel Open Source Technology Center
