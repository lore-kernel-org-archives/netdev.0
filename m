From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 3/9] net: dsa: mv88e6xxx: add support for VTU ops
Date: Tue, 2 Jun 2015 15:05:45 +0200
Message-ID: <20150602130545.GS22739@lunn.ch>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1433208470-25338-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49977 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752607AbbFBNLO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 09:11:14 -0400
Content-Disposition: inline
In-Reply-To: <1433208470-25338-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
> +			    u16 bridge_flags)
> +{
> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	struct mv88e6xxx_vtu_entry entry = { 0 };
> +	int prev_vid = vid ? vid - 1 : 4095;
> +	int i, ret;
> +
> +	/* Bringing an interface up adds it to the VLAN 0. Ignore this. */
> +	if (!vid)
> +		return 0;
> +
> +	/* The DSA port-based VLAN setup reserves FID 0 to DSA_MAX_PORTS;
> +	 * we will use the next FIDs for 802.1q;
> +	 * thus, forbid the last DSA_MAX_PORTS VLANs.
> +	 */
> +	if (vid > 4095 - DSA_MAX_PORTS)
> +		return -EINVAL;

I'm not sure about this. I've setup systems where i've used VLANs from
the top down to differentiate them from other VLANs going from the
bottom up. We might want to dynamically assign FIDs to VLANs rather
than have a static mapping.

     Andrew
