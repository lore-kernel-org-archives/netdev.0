From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 07/11] net: dsa: mv88e6xxx: add port link setter
Date: Wed, 02 Nov 2016 23:31:52 +0100
Message-ID: <8760o55x9j.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161101032023.32762-1-vivien.didelot@savoirfairelinux.com> <20161101032023.32762-8-vivien.didelot@savoirfairelinux.com> <20161101094313.GB2802@lunn.ch> <87shra4rlu.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me> <20161102091629.GA384@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161102091629.GA384@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Wed, Nov 02, 2016 at 02:07:09AM +0100, Vivien Didelot wrote:
>> Hi Andrew,
>> 
>> Andrew Lunn <andrew@lunn.ch> writes:
>> 
>> >> +#define LINK_UNKNOWN	-1
>> >> +
>> >> +	/* Port's MAC link state
>> >> +	 * LINK_UNKNOWN for normal link detection, 0 to force link down,
>> >> +	 * otherwise force link up.
>> >> +	 */
>> >> +	int (*port_set_link)(struct mv88e6xxx_chip *chip, int port, int link);
>> >
>> > Maybe LINK_AUTO would be better than UNKNOWN? Or LINK_UNFORCED.
>> 
>> I used LINK_UNKNOWN to be consistent with the supported SPEED_UNKNOWN
>> and DUPLEX_UNKNOWN values of PHY devices.
>
> These are i think for reporting back to user space what duplex or link
> is currently being used. But here you are setting, not
> reporting. Setting something to an unknown state is rather odd, and in
> fact, it is not unknown, it is unforced.

Do you expect to return an error if adjust_link is called with
phydev->duplex == DUPLEX_UNKNOWN, or, do you expect to fallback to
unforced duplex when setting such value?

Thanks,

        Vivien
