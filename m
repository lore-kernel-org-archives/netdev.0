From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH net-next 1/2] net: bridge: add switchdev attr for port
 bridging
Date: Wed, 9 Mar 2016 22:26:35 +0300
Message-ID: <56E078EB.7040509@cogentembedded.com>
References: <1457545368-20647-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1457545368-20647-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	nikolay@cumulusnetworks.com, Elad Raz <eladr@mellanox.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:35700 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753773AbcCIT0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 14:26:39 -0500
Received: by mail-lb0-f180.google.com with SMTP id bc4so80125586lbc.2
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 11:26:39 -0800 (PST)
In-Reply-To: <1457545368-20647-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/09/2016 08:42 PM, Vivien Didelot wrote:

> Add a new SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF switchdev attribute which is
> set before adding a port to a bridge and deleting a port from a bridge.
>
> The main purpose for this attribute is to provide switchdev users a
> simple and common way to retrieve bridging information, instead of
> implementing complex notifier blocks to listen to global netdev events.
>
> We can also imagine a switchdev user returning an error different from
> -EOPNOTSUPP in the prepare phase to prevent a port from being bridged.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>   include/net/switchdev.h |  2 ++
>   net/bridge/br_if.c      | 27 +++++++++++++++++++++++++++
>   2 files changed, 29 insertions(+)
>
[...]
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index a73df33..105b9fd 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -28,6 +28,24 @@
>
>   #include "br_private.h"
>
> +static int switchdev_bridge_if(struct net_device *dev, struct net_bridge *br,
> +			       bool join)
> +{
> +	struct switchdev_attr attr = {
> +		.orig_dev = br->dev,
> +		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF,
> +		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
> +		.u.join = join,
> +	};
> +	int err;
> +
> +	err = switchdev_port_attr_set(dev, &attr);
> +	if (err && err != -EOPNOTSUPP)

    Enough to only do the latter comparison.

> +		return err;
> +
> +	return 0;
> +}
> +
>   /*
>    * Determine initial path cost based on speed.
>    * using recommendations from 802.1d standard
[...]

MBR, Sergei
