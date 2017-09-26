From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/5] net: dsa: use generic slave phydev
Date: Tue, 26 Sep 2017 16:55:36 -0700
Message-ID: <28fd7053-eb5a-730e-b2db-33df44d6a3b6@gmail.com>
References: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/26/2017 02:15 PM, Vivien Didelot wrote:
> DSA currently stores a phy_device pointer in each slave private
> structure. This requires to implement our own ethtool ksettings
> accessors and such.
> 
> This patchset removes the private phy_device in favor of the one
> provided in the net_device structure, and thus allows us to use the
> generic phy_ethtool_* functions.

For this series:

Tested-by: Florian Fainelli <f.fainelli@gmail.com>

On bcm_sf2 (7445 and 7278) along with the externally attached BCM53125
switch that needs the special MDIO read/write divert. We properly attach
to the right PHY devices in all cases.

Also tested unbind/bind, working correctly.

Thanks!

> 
> Vivien Didelot (5):
>   net: dsa: return -ENODEV is there is no slave PHY
>   net: dsa: use slave device phydev
>   net: dsa: use phy_ethtool_get_link_ksettings
>   net: dsa: use phy_ethtool_set_link_ksettings
>   net: dsa: use phy_ethtool_nway_reset
> 
>  net/dsa/dsa_priv.h |   1 -
>  net/dsa/slave.c    | 143 +++++++++++++++++++----------------------------------
>  2 files changed, 52 insertions(+), 92 deletions(-)
> 


-- 
Florian
