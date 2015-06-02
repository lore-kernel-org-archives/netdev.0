From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC 6/9] net: dsa: mv88e6352: allow egress of unknown multicast
Date: Tue, 02 Jun 2015 07:20:53 -0700
Message-ID: <556DBBC5.5050009@roeck-us.net>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-7-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:46272 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758792AbbFBOU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 10:20:58 -0400
In-Reply-To: <1433208470-25338-7-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2015 06:27 PM, Vivien Didelot wrote:
> This patch disables egress of unknown unicast destination addresses.
>

Hi Vivien,

seems to me this patch is unrelated to the rest of the series.

Not sure if we really want this. If an address is in the arp cache
but has timed out from the bridge database, any unicast to that address
will no longer be sent. If the bridge database has been flushed for some
reason, such as a spanning tree reconfiguration, we'll have a hard time
to send anything.

What is the problem you are trying to solve with this patch ?

Thanks,
Guenter

> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>   drivers/net/dsa/mv88e6xxx.c | 3 ++-
>   drivers/net/dsa/mv88e6xxx.h | 5 +++++
>   2 files changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 49ef2f8..d2beb10 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1686,7 +1686,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>   	    mv88e6xxx_6185_family(ds))
>   		reg = PORT_CONTROL_IGMP_MLD_SNOOP |
>   		PORT_CONTROL_USE_TAG | PORT_CONTROL_USE_IP |
> -		PORT_CONTROL_STATE_FORWARDING;
> +		PORT_CONTROL_STATE_FORWARDING |
> +		PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_UNICAST_DA;
>   	if (dsa_is_cpu_port(ds, port)) {
>   		if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds))
>   			reg |= PORT_CONTROL_DSA_TAG;
> diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
> index f4ea66a..412d14e 100644
> --- a/drivers/net/dsa/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx.h
> @@ -117,6 +117,11 @@
>   #define PORT_CONTROL_STATE_BLOCKING	0x01
>   #define PORT_CONTROL_STATE_LEARNING	0x02
>   #define PORT_CONTROL_STATE_FORWARDING	0x03
> +#define PORT_CONTROL_EGRESS_FLOODS_MASK				(0x03 << 2)
> +#define PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_ANY_DA		(0x00 << 2)
> +#define PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_MULTICAST_DA	(0x01 << 2)
> +#define PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_UNICAST_DA	(0x02 << 2)
> +#define PORT_CONTROL_EGRESS_FLOODS_ANY_DA			(0x03 << 2)
>   #define PORT_CONTROL_1		0x05
>   #define PORT_BASE_VLAN		0x06
>   #define PORT_DEFAULT_VLAN	0x07
>
