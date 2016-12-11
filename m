From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: Fix opps when adding vlan bridge
Date: Sun, 11 Dec 2016 16:02:37 -0500
Message-ID: <87a8c2w55e.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1481486839-19502-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41732 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753620AbcLKVCq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 16:02:46 -0500
In-Reply-To: <1481486839-19502-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> @@ -1804,6 +1807,9 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
>  			    chip->ports[port].bridge_dev)
>  				break; /* same bridge, check next VLAN */
>  
> +			if (!chip->ports[i].bridge_dev)
> +				continue;
> +

The above truncated test:

			if (chip->ports[i].bridge_dev ==
			    chip->ports[port].bridge_dev)
				break; /* same bridge, check next VLAN */

should handle the case where bridge_dev is NULL, but if you want to
explicitly test it, I'd move it before this statement.

>  			netdev_warn(ds->ports[port].netdev,
>  				    "hardware VLAN %d already used by %s\n",
>  				    vlan.vid,


Thanks,

        Vivien
