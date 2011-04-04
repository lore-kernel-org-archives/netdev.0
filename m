From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/7] tg3: Add 5720 ASIC rev
Date: Mon, 04 Apr 2011 11:37:42 -0700
Message-ID: <1301942262.1941.60.camel@Joe-Laptop>
References: <1301941495-8069-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4502 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752109Ab1DDSho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:37:44 -0400
In-Reply-To: <1301941495-8069-2-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-04 at 11:24 -0700, Matt Carlson wrote:
> This patch adds support for the 5720 ASIC rev.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Reviewed-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/tg3.c |   67 +++++++++++++++++++++++++++++++++++++---------------
>  drivers/net/tg3.h |    5 ++++
>  2 files changed, 52 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index b7e03a6..b105cdd 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -98,12 +98,14 @@
>   */
>  #define TG3_RX_STD_RING_SIZE(tp) \
>  	((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 || \
> -	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) ? \
> +	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 || \
> +	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) ? \

Maybe it'd be better to convert all of these:

	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)

tests to a common functions something like:

static bool can_asic_<foo>(struct tg3 *tp)
{
	int rev = GET_ASIC_REV(tp->pci_chip_rev_id);
	return (rev == ASIC_REV_5717) ||
	       (rev == ASIC_REV_5719) ||
	       (rev == ASIC_REV_5720);
}


