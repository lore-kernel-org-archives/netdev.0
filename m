From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 06/18] PCI-X/PCI-Express read control interfaces: use
 them in myrinet
Date: Tue, 14 Aug 2007 01:30:13 -0400
Message-ID: <46C13DE5.2070107@garzik.org>
References: <200708102105.l7AL5H0a008960@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.oruba@amd.com, rolandd@cisco.com,
	shemminger@linux-foundation.org
To: akpm@linux-foundation.org, brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46946 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936849AbXHNFaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:30:17 -0400
In-Reply-To: <200708102105.l7AL5H0a008960@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: "Peter Oruba" <peter.oruba@amd.com>
> 
> These driver changes incorporate the proposed PCI-X / PCI-Express read byte
> count interface.  Reading and setting those valuse doesn't take place
> "manually", instead wrapping functions are called to allow quirks for some
> PCI bridges.
> 
> Signed-off by: Peter Oruba <peter.oruba@amd.com>
> Based on work by Stephen Hemminger <shemminger@linux-foundation.org>
> Cc: Roland Dreier <rolandd@cisco.com>
> Cc: Brice Goglin <brice@myri.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/myri10ge/myri10ge.c |    3 +--
>  1 files changed, 1 insertion(+), 2 deletions(-)
> 
> diff -puN drivers/net/myri10ge/myri10ge.c~pci-x-pci-express-read-control-interfaces-myrinet drivers/net/myri10ge/myri10ge.c
> --- a/drivers/net/myri10ge/myri10ge.c~pci-x-pci-express-read-control-interfaces-myrinet
> +++ a/drivers/net/myri10ge/myri10ge.c
> @@ -2884,8 +2884,7 @@ static int myri10ge_probe(struct pci_dev
>  			status);
>  		goto abort_with_netdev;
>  	}
> -	val = (val & ~PCI_EXP_DEVCTL_READRQ) | (5 << 12);
> -	status = pci_write_config_word(pdev, cap + PCI_EXP_DEVCTL, val);
> +	status = pcie_set_readrq(pdev, 4096);


I presume Brice will resend this one to me, next time he pushes...

