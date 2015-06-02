From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC 8/9] net: dsa: mv88e6352: set port 802.1Q mode to Secure
Date: Tue, 02 Jun 2015 16:28:57 -0700
Message-ID: <556E3C39.3090709@roeck-us.net>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-9-git-send-email-vivien.didelot@savoirfairelinux.com>
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
Received: from bh-25.webhostbox.net ([208.91.199.152]:46500 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbbFBX3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 19:29:03 -0400
In-Reply-To: <1433208470-25338-9-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2015 06:27 PM, Vivien Didelot wrote:
> This commit changes the 802.1Q mode of each port from Disabled to
> Secure. This enables the VLAN support, by checking the VTU entries on
> ingress.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>   drivers/net/dsa/mv88e6xxx.c | 14 +++++++-------
>   drivers/net/dsa/mv88e6xxx.h |  5 +++++
>   2 files changed, 12 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index ed49bd8..35243d8 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1723,13 +1723,11 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>   			goto abort;
>   	}
>
> -	/* Port Control 2: don't force a good FCS, set the maximum
> -	 * frame size to 10240 bytes, don't let the switch add or
> -	 * strip 802.1q tags, don't discard tagged or untagged frames
> -	 * on this port, do a destination address lookup on all
> -	 * received packets as usual, disable ARP mirroring and don't
> -	 * send a copy of all transmitted/received frames on this port
> -	 * to the CPU.
> +	/* Port Control 2: don't force a good FCS, set the maximum frame size to
> +	 * 10240 bytes, enable secure 802.1q tags, don't discard tagged or
> +	 * untagged frames on this port, do a destination address lookup on all
> +	 * received packets as usual, disable ARP mirroring and don't send a
> +	 * copy of all transmitted/received frames on this port to the CPU.
>   	 */
>   	reg = 0;
>   	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
> @@ -1751,6 +1749,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>   			reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
>   	}
>
> +	reg |= PORT_CONTROL_2_8021Q_SECURE;
> +

Vivien,

With this patch, my non-VLAN configuration fails; it appears that untagged
packets are no longer received. I found two possible solutions:
- Use PORT_CONTROL_2_8021Q_FALLBACK
- Explicitly add a VLAN entry for vid=0.

Guenter
