From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 06/21] net: dsa: mv88e6xxx: factorize MAC address setting
Date: Sat, 07 May 2016 16:37:03 -0400
Message-ID: <878tzlfvv4.fsf@ketchup.mtl.sfl>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1462571843-14397-7-git-send-email-vivien.didelot@savoirfairelinux.com> <20160506222320.GB2073@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160506222320.GB2073@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> @@ -378,6 +385,7 @@ enum mv88e6xxx_cap {
>>  #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
>>  #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
>>  #define MV88E6XXX_FLAG_SMI_PHY		BIT(MV88E6XXX_CAP_SMI_PHY)
>> +#define MV88E6XXX_FLAG_SWITCH_MAC	BIT(MV88E6XXX_CAP_SWITCH_MAC_WOL_WOF)
>>  #define MV88E6XXX_FLAG_TEMP		BIT(MV88E6XXX_CAP_TEMP)
>>  #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT(MV88E6XXX_CAP_TEMP_LIMIT)
>
> There is a general pattern here that the flag has a name derived from
> the capability. Except you dropped the WOL_WOF here. It would probably
> be better to not have WOL_WOF at all.

Indeed, I did that because the global 2 register 0x0D "Switch
MAC/WoL/WoF" is used to indirectly configure the switch MAC address, the
Wake on Lan and Wake on Frame. So I explicitly named the capability
MV88E6XXX_CAP_SWITCH_MAC_WOL_WOF and the flag for the switch MAC
MV88E6XXX_FLAG_SWITCH_MAC.

So if we add support for WoL, we can then define:

    #define MV88E6XXX_FLAG_WOL BIT(MV88E6XXX_CAP_SWITCH_MAC_WOL_WOF)

But I can get rid of it if it feels confusing.

Thanks,

        Vivien
