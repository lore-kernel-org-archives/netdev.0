From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v5 20/21] rocker: make checkpatch -f clean
Date: Tue, 05 May 2015 10:45:47 -0700
Message-ID: <1430847947.3943.4.camel@perches.com>
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
Received: from smtprelay0239.hostedemail.com ([216.40.44.239]:60728 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965493AbbEERpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 13:45:52 -0400
In-Reply-To: <1430847297-15728-21-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-05 at 10:34 -0700, sfeldma@gmail.com wrote:
> Well almost clean: ignore the CHECKs for space after cast operator.

I think, because this uses relatively long identifiers,
that you might as well ignore > 80 column lines length
warnings.

> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
[]
> @@ -1418,9 +1418,10 @@ static int rocker_event_link_change(struct rocker *rocker,
>  	if (!attrs[ROCKER_TLV_EVENT_LINK_CHANGED_PPORT] ||
>  	    !attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LINKUP])
>  		return -EIO;
> -	port_number =
> -		rocker_tlv_get_u32(attrs[ROCKER_TLV_EVENT_LINK_CHANGED_PPORT]) - 1;
> -	link_up = rocker_tlv_get_u8(attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LINKUP]);
> +	port_number = rocker_tlv_get_u32(
> +		attrs[ROCKER_TLV_EVENT_LINK_CHANGED_PPORT]) - 1;
> +	link_up = rocker_tlv_get_u8(
> +		attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LINKUP]);

These would probably be better on single lines.

Maybe it'd be OK to avoid the rocker_tlv_ prefix
and/or add a helper macro/define for the
	rocker_tlv_<foo>(attrs[ROCKER_TLV_<BAR>
style to shorten the line length.

Otherwise, all the line breaks just seem to make
it harder to read.

> @@ -1686,9 +1687,12 @@ rocker_cmd_get_port_settings_ethtool_proc(struct rocker *rocker,
>  	    !info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_AUTONEG])
>  		return -EIO;
>  
> -	speed = rocker_tlv_get_u32(info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_SPEED]);
> -	duplex = rocker_tlv_get_u8(info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_DUPLEX]);
> -	autoneg = rocker_tlv_get_u8(info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_AUTONEG]);
> +	speed = rocker_tlv_get_u32(
> +		info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_SPEED]);
> +	duplex = rocker_tlv_get_u8(
> +		info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_DUPLEX]);
> +	autoneg = rocker_tlv_get_u8(
> +		info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_AUTONEG]);

etc...
