From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PKT_SCHED] netem: Orphan SKB when adding to queue.
Date: Mon, 23 Oct 2006 19:08:17 +0200
Message-ID: <453CF701.2000807@trash.net>
References: <200610231700.k9NH0Dck016668@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:21921 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964896AbWJWRIU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 13:08:20 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <200610231700.k9NH0Dck016668@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linux Kernel Mailing List wrote:
> commit 4e8a5201506423e0241202de1349422af4260296
> tree e562a6cdbee37e3805551af92b264fa93d722c4b
> parent 6a43487f43fbd4e03c606dcb62b98374a3af88fc
> author David S. Miller <davem@sunset.davemloft.net> 1161576033 -0700
> committer David S. Miller <davem@sunset.davemloft.net> 1161576033 -0700
> 
> [PKT_SCHED] netem: Orphan SKB when adding to queue.
> 
> The networking emulator can queue SKBs for a very long
> time, so if you're using netem on the sender side for
> large bandwidth/delay product testing, the SKB socket
> send queue sizes become artificially larger.
> 
> Correct this by calling skb_orphan() in netem_enqueue().
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
>  drivers/pci/quirks.c  |    4 ++--
>  net/sched/sch_netem.c |    2 ++
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> index e8a7f1b..ecf8e4d 100644
> --- a/drivers/pci/quirks.c
> +++ b/drivers/pci/quirks.c
> @@ -1634,7 +1634,7 @@ DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_N
>   * is marked here since the boot video device will be the only enabled
>   * video device at this point.
>   */
> -
> +#if 0
>  static void __devinit fixup_video(struct pci_dev *pdev)
>  {
>  	struct pci_dev *bridge;
> @@ -1663,7 +1663,7 @@ static void __devinit fixup_video(struct
>  	}
>  }
>  DECLARE_PCI_FIXUP_HEADER(PCI_ANY_ID, PCI_ANY_ID, fixup_video);
> -
> +#endif


This part looks like you accidentally committed it.

