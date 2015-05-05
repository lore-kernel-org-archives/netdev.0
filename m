From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v5 20/21] rocker: make checkpatch -f clean
Date: Tue, 05 May 2015 11:22:56 -0700
Message-ID: <1430850176.6575.6.camel@perches.com>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
	 <1430847297-15728-21-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch, simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0068.hostedemail.com ([216.40.44.68]:38076 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753227AbbEESXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 14:23:01 -0400
In-Reply-To: <1430847297-15728-21-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-05 at 10:34 -0700, sfeldma@gmail.com wrote:
[]
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c

trivia:

> @@ -4699,8 +4704,9 @@ static int rocker_port_poll_tx(struct napi_struct *napi, int budget)
>  		if (err == 0) {
>  			rocker_port->dev->stats.tx_packets++;
>  			rocker_port->dev->stats.tx_bytes += skb->len;
> -		} else
> +		} else {
>  			rocker_port->dev->stats.tx_errors++;
> +		}

This might be sped up a bit with a likely

		if (likely(!err)) {
			rocker_port->dev->stats.tx_packets++;
			rocker_port->dev->stats.tx_bytes += skb->len;
		} else {
			rocker_port->dev->stats.tx_errors++;
		}
