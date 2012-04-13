From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/9] atl1: make driver napi compatible
Date: Fri, 13 Apr 2012 18:15:15 +0100
Message-ID: <1334337315.2606.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <1334333394-38404-1-git-send-email-antonz@parallels.com>
	 <1334333394-38404-3-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <csnook@redhat.com>, <khorenko@parallels.com>
To: Tony Zelenoff <antonz@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:45557 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755442Ab2DMRPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 13:15:19 -0400
In-Reply-To: <1334333394-38404-3-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-13 at 20:09 +0400, Tony Zelenoff wrote:
> This is first step, here there is no fine interrupt
> disabling which cause TX/ERR interrupts stalling when
> RX scheduled ints processed.
> 
> Signed-off-by: Tony Zelenoff <antonz@parallels.com>
> ---
>  drivers/net/ethernet/atheros/atlx/atl1.c |   46 ++++++++++++++++++++++++++----
>  drivers/net/ethernet/atheros/atlx/atl1.h |    1 +
>  2 files changed, 41 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
> index 6438239..d39c1b9 100644
> --- a/drivers/net/ethernet/atheros/atlx/atl1.c
> +++ b/drivers/net/ethernet/atheros/atlx/atl1.c
> @@ -1917,7 +1917,7 @@ next:
>  	return num_alloc;
>  }
>  
> -static void atl1_intr_rx(struct atl1_adapter *adapter)
> +static int atl1_intr_rx(struct atl1_adapter *adapter, int budget)
>  {
>  	int i, count;
>  	u16 length;
> @@ -1933,7 +1933,7 @@ static void atl1_intr_rx(struct atl1_adapter *adapter)
>  
>  	rrd_next_to_clean = atomic_read(&rrd_ring->next_to_clean);
>  
> -	while (1) {
> +	while (count <= budget) {
[...]

Off by one; the test should be count < budget.  Otherwise you can exit
with count == budget + 1 and net_rx_action() will WARN you about that.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
