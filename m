From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 5/6] net: dsa: mv88e6xxx: describe PHY page and SerDes
Date: Tue, 16 Aug 2016 10:57:56 -0400
Message-ID: <874m6kzrpn.fsf@ketchup.mtl.sfl>
References: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com> <20160815211902.2236-6-vivien.didelot@savoirfairelinux.com> <20160816011618.GL24664@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160816011618.GL24664@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Mon, Aug 15, 2016 at 05:19:01PM -0400, Vivien Didelot wrote:
>> +static int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
>> +				   u8 page, int reg, u16 *val)
>> +{
>> +	int err;
>> +
>> +	/* There is no paging for registers 22 */
>> +	if (reg == PHY_PAGE)
>> +		return -EINVAL;
>
> This whole paging scheme only works for internal PHYs, or external
> PHYs which happen to be Marvell PHYs. We need to be a little bit
> careful here and ensure these functions don't get used for external
> PHYs when we don't know who manufactured them. 
>
> At the moment the code is O.K, we only access SERDES or temperature
> sensors for a given port. But i wounder if adding a comment would be
> wise?

That is a good point, I thought about that too. I was thinking about
adding an internal_phys bitmask to the chip info structures and check it
in mv88e6xxx_phy_page_get(), so we could return -EINVAL for external
PHYs, since the switch driver isn't supposed to access their pages.

But I also think that most of the PHY code should be moved to a proper
PHY driver, since they are valid Marvell chips with their own PHY IDs.

Until we move the PHY and SERDES code out of the mv88e6xxx driver, I
think we are safe.

Thanks,

        Vivien
