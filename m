From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] ethtool: Protect {get,set}_phy_tunable with PHY
 device mutex
Date: Tue, 22 Nov 2016 13:02:50 -0800
Message-ID: <7d234447-d18c-1efd-a9bd-01014fa43391@gmail.com>
References: <20161122201316.10830-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bcm-kernel-feedback-list@broadcom.com,
        andrew@lunn.ch, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35437 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933713AbcKVVPX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 16:15:23 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so3073679pga.2
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 13:15:22 -0800 (PST)
In-Reply-To: <20161122201316.10830-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2016 12:13 PM, Florian Fainelli wrote:
> PHY drivers should be able to rely on the caller of {get,set}_tunable to
> have acquired the PHY device mutex, in order to both serialize against
> concurrent calls of these functions, but also against PHY state machine
> changes. All ethtool PHY-level functions do this, except
> {get,set}_tunable, so we make them consistent here as well.
> 
> Fixes: 968ad9da7e0e ("ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

David, please discard, this is going to create problems for the
Microsemi PHY driver since it also acquires phydev->lock. (patch has
been marked accordingly in patchwork.
Thanks!
-- 
Florian
