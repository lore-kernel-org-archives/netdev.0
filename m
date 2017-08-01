From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 10/11] net: dsa: mv88e6xxx: remove EEE support
Date: Tue, 01 Aug 2017 11:36:13 -0400
Message-ID: <87r2wv2tci.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com> <20170731221719.16695-11-vivien.didelot@savoirfairelinux.com> <20170801142843.GE23157@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801142843.GE23157@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Mon, Jul 31, 2017 at 06:17:18PM -0400, Vivien Didelot wrote:
>> The PHY's EEE settings are already accessed by the DSA layer through the
>> Marvell PHY driver and there is nothing to be done for switch's MACs.
>
> I'm confused, or missing something. Does not patch #1 mean that if the
> DSA driver does not have a set_eee function, we always return -ENODEV
> in slave.c?

If there is a PHY, phy_init_eee (if eee_enabled is true) and
phy_ethtool_set_eee is called. If there is a .set_eee op, it is
called. If both are absent, -ENODEV is returned.

> There might be nothing to configure here, but some of the switches do
> support EEE. So we need at least a NOP set_eee. Better still it should
> return -ENODEV for those switches which don't actually support EEE,
> and 0 for those that do?

As I explain in a commit message, I didn't want to make the EEE ops
mandatory, because it makes it impossible for the DSA layer to
distinguish whether the driver did not update the ethtool_eee structure
because there is nothing to do on the port's MAC side (e.g. mv88e6xxx or
qca8k) or if it returned EEE disabled. To avoid confusion, I prefered to
make the ops optional, making the phy_* calls enough in the first case.

That being said, if you don't share this point of view and prefer to
define an inline dsa_set_eee_noop() function, I don't mind, since this
allows the DSA layer to make the distinction.


Thanks,

        Vivien
