From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 3/4] net-next: dsa: Add support for multiple cpu ports.
Date: Wed, 4 Jan 2017 15:01:05 +0100
Message-ID: <20170104140105.GL10768@lunn.ch>
References: <1483515484-21793-1-git-send-email-john@phrozen.org>
 <1483515484-21793-4-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42905 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751630AbdADOBN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 09:01:13 -0500
Content-Disposition: inline
In-Reply-To: <1483515484-21793-4-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2017 at 08:38:03AM +0100, John Crispin wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> 
> Some boards have two CPU interfaces connected to the switch, e.g. WiFi
> access points, with 1 port labeled WAN, 4 ports labeled lan1-lan4, and
> two port connected to the SoC.
> 
> This patch extends DSA to allows both CPU ports to be used. The "cpu"
> node in the DSA tree can now have a phandle to the host interface it
> connects to. Each user port can have a phandle to a cpu port which
> should be used for traffic between the port and the CPU. Thus simple
> load sharing over the two CPU ports can be achieved.
> 
> Signed-off-by: John Crispin <john@phrozen.org>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  include/net/dsa.h  |   21 ++++++++++++++++++++-
>  net/dsa/dsa2.c     |   36 ++++++++++++++++++++++++++++++------
>  net/dsa/dsa_priv.h |    5 +++++
>  net/dsa/slave.c    |   27 ++++++++++++++++-----------
>  4 files changed, 71 insertions(+), 18 deletions(-)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index b122196..f68180b 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -60,6 +60,8 @@ struct dsa_chip_data {
>  	 */
>  	char		*port_names[DSA_MAX_PORTS];
>  	struct device_node *port_dn[DSA_MAX_PORTS];
> +	struct net_device *port_ethernet[DSA_MAX_PORTS];
> +	int		port_cpu[DSA_MAX_PORTS];

Hi John

My proof of concept patches have "bit rotted" a bit. When implementing
dsa2, i removed the use of dsa_chip_data, aka cd, from all the drivers
and the new binding does not use it at all. I don't want to add it
back again. When Florain removes the old binding in 6 months time, i
expect dsa_chip_data and dsa_platform_data will be removed.

I would be tempted to put these two members into the dsa_port
structure.

	Andrew
