From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/4] net: dsa: mv88e6xxx: Add support for ethernet switch
 88E6341/88E6141
Date: Mon, 19 Dec 2016 15:52:27 +0100
Message-ID: <20161219145227.GC10048@lunn.ch>
References: <20161219141610.30934-1-romain.perier@free-electrons.com>
 <20161219141610.30934-4-romain.perier@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>
To: Romain Perier <romain.perier@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58656 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755685AbcLSOwd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Dec 2016 09:52:33 -0500
Content-Disposition: inline
In-Reply-To: <20161219141610.30934-4-romain.perier@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Romain

> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 76d944e..72ba24b 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -4086,6 +4086,20 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
>  		.ops = &mv88e6321_ops,
>  	},
>  
> +	[MV88E6341] = {
> +		.prod_num = PORT_SWITCH_ID_PROD_NUM_6341,
> +		.family = MV88E6XXX_FAMILY_6352,
> +		.name = "Marvell 88E6341",
> +		.num_databases = 4096,
> +		.num_ports = 6,
> +		.port_base_addr = 0x10,
> +		.global1_addr = 0x1b,
> +		.age_time_coeff = 15000,
> +		.tag_protocol = DSA_TAG_PROTO_EDSA,
> +		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
> +		.ops = &mv88e6352_ops,

Even if it i 100% compatible with the 6532, you should still add an
ops structure for it. All chips have their own, even when the are
exactly the same as other in the family.

> --- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> @@ -86,6 +86,7 @@
>  #define PORT_SWITCH_ID_PROD_NUM_6097	0x099
>  #define PORT_SWITCH_ID_PROD_NUM_6131	0x106
>  #define PORT_SWITCH_ID_PROD_NUM_6320	0x115
> +#define PORT_SWITCH_ID_PROD_NUM_6341	0x340
>  #define PORT_SWITCH_ID_PROD_NUM_6123	0x121
>  #define PORT_SWITCH_ID_PROD_NUM_6161	0x161

Ah, err..

These should be in numerical order of the macro.
PORT_SWITCH_ID_PROD_NUM_6320 is however in the wrong place.  Please
put the 6341 after the 6321.

Thanks
	Andrew
