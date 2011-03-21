From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 1/1] solos-pci: Fix regression introduced by newest
 firmware
Date: Mon, 21 Mar 2011 03:01:36 +0000
Message-ID: <1300676496.26693.318.camel@localhost>
References: <4D86AF4F.5010203@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"linux-atm-general@lists.sourceforge.net"
	<linux-atm-general@lists.sourceforge.net>
To: Philip Prindeville <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:56917 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643Ab1CUDBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 23:01:41 -0400
In-Reply-To: <4D86AF4F.5010203@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-03-20 at 18:52 -0700, Philip Prindeville wrote:
> The newest FPGA firmware on the Solos processors correctly signals
> carrier transitions, bitrate, etc.
> 
> The driver previously ignored these messages, and the physical state
> was always ATM_PHY_SIG_UNKNOWN.
> 
> Now that the board reports its state, we expose a bug whereby the
> transition from UNKNOWN to LOST causes us to release all VC's.
> 
> We don't delete any VC's, but instead just send an indication of
> carrier change.
> 
> Signed-off-by: Philip A Prindeville <philipp@redfish-solutions.com>
> ---
> 
> --- a/drivers/atm/solos-pci.c	2011-03-20 15:27:40.000000000 -0600
> +++ b/drivers/atm/solos-pci.c	2011-03-20 16:32:11.000000000 -0600
> @@ -382,8 +382,10 @@ static int process_status(struct solos_c
> 
>   	/* Anything but 'Showtime' is down */
>   	if (strcmp(state_str, "Showtime")) {
>   		atm_dev_signal_change(card->atmdev[port], ATM_PHY_SIG_LOST);
> +#if 0
>   		atm_dev_release_vccs(card->atmdev[port]);
> +#endif

Either remove it or don't.  #if 0 is for people without version control.

Ben.

>   		dev_info(&card->dev->dev, "Port %d: %s\n", port, state_str);
> 		return 0;
> 	}
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

