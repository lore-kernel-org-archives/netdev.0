From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Tue, 13 Sep 2016 20:07:19 +0200
Message-ID: <44865cc8-19bf-54dc-ad05-82bdaa648eeb@phrozen.org>
References: <1473669337-21221-1-git-send-email-john@phrozen.org>
 <1473669337-21221-4-git-send-email-john@phrozen.org>
 <20160913004047.GB3585@lunn.ch>
 <7f9c1463-1cc0-e230-e7fe-dbb434427251@phrozen.org>
 <20160913155926.GP11400@lunn.ch>
 <371ed906-5ce8-0553-1400-11f0abf4b489@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, qsdk-review@qca.qualcomm.com
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <371ed906-5ce8-0553-1400-11f0abf4b489@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 13/09/2016 19:09, Florian Fainelli wrote:
> On 09/13/2016 08:59 AM, Andrew Lunn wrote:
>>> Hi Andrew,
>>>
>>> this function does indeed duplicate the functionality of
>>> phy_ethtool_get_eee() with the small difference, that e->eee_active is
>>> also set which phy_ethtool_get_eee() does not set.
>>>
>>> dsa_slave_get_eee() will call phy_ethtool_get_eee() right after the
>>> get_eee() op has been called. would it be ok to move the code setting
>>> eee_active to  phy_ethtool_get_eee().
> 
> Humm, AFAIR, the reason why eee_active is set outside of
> phy_ethtool_set_eee() is because this is a MAC + PHY thing, both need to
> agree and support that, and so while the PHY may be configured to have
> EEE advertised and enabled, you also need to take care of the MAC
> portion and enable EEE in there as well. Is not there such a thing for
> the qca8k switch where the PHY needs to be configured through the
> standard phylib calls, but the switch's transmitter/receiver also needs
> to have EEE enabled?
>

Hi Florian,

the switch needs to enable the eee on a per mac absis, but there is no
way to tell if the autonegotiate worked and eee is enabled without
reading the phys registers.

setting the eee_active inside phy_ethtool_get_eee() would break those
dsa drivers that have a register telling if AN worked. if it is ok i
will just call phy_ethtool_get_eee() inside get_eee().

	John
