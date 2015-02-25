From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next v3 2/3] net: dsa: integrate with SWITCHDEV for
 HW bridging
Date: Tue, 24 Feb 2015 21:44:28 -0800
Message-ID: <54ED613C.3020409@roeck-us.net>
References: <1424812534-8936-1-git-send-email-f.fainelli@gmail.com> <1424812534-8936-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:51401 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbbBYFpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 00:45:12 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YQUmV-002jhZ-MI
	for netdev@vger.kernel.org; Wed, 25 Feb 2015 05:45:11 +0000
In-Reply-To: <1424812534-8936-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2015 01:15 PM, Florian Fainelli wrote:
> In order to support bridging offloads in DSA switch drivers, select
> NET_SWITCHDEV to get access to the port_stp_update and parent_get_id
> NDOs that we are required to implement.
>
> To facilitate the integratation at the DSA driver level, we implement 3
> types of operations:
>
> - port_join_bridge
> - port_leave_bridge
> - port_stp_update
>
> DSA will resolve which switch ports that are currently bridge port
> members as some Switch hardware/drivers need to know about that to limit
> the register programming to just the relevant registers (especially for
> slow MDIO buses).
>
> We also take care of setting the correct STP state when slave network
> devices are brought up/down while being bridge members.
>
> Finally, when a port is leaving the bridge, we make sure we set in
> BR_STATE_FORWARDING state, otherwise the bridge layer would leave it
> disabled as a result of having left the bridge.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Guenter Roeck <linux@roeck-us.net>

And with my code adding support for HW bridging to the mv88e6352 driver:

Tested-by: Guenter Roeck <linux@roeck-us.net>

Guenter
