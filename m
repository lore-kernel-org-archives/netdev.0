From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 00/17] net: dsa: mv88e6xxx: rework ATU support
Date: Sat, 11 Mar 2017 18:27:00 -0800
Message-ID: <d6ad6ba8-3b60-d017-24a9-1f19649d7b4d@gmail.com>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 03/11/17 à 13:12, Vivien Didelot a écrit :
> The purpose of this patch series is to rework the code related to the
> Address Translation Unit (ATU), and bring support for it to the 88E6390
> family of switch chips.
> 
> All Global (1) ATU related code have been reworked and moved to its own
> file. Some port related bits used for ATU configuration (such as the
> Learn2All and MessagePort feature) have also been taken care of.
> 
> The ports' mode and egress flooding mode have been refactored to fix the
> egress of frames with unknown unicast or multicast destination address,
> and write all these bits regardless the port mode (Normal, DSA, etc.)
> 
> Finally remove the eth_addr_greater which was only used by mv88e6xxx.

Just some general note on the way the driver seems to be going there
seems to be a multiplication of new ops being introduced, and most of
them seem to default to the mv88e6xxx (generic) ones. Should you do
something like:

if (!ops->foo)
	ops->foo = mv88e6xxx_foo

Such that you reduce the possibility for a specific switch model to lack
such an operation?

> 
> Changes in v2:
>   - add Reviewed-by tags
>   - split mv88e6xxx_g1_atu_set_age_time and mv88e6xxx_atu_setup addition
>   - remove DSA_TAG_PROTO_TRAILER check
>   - split Message Port and Learn2All addition
>   - remove unused MV88E6XXX_FLAG_G1_ATU_FID flag
>   - add dsa_is_normal_port helper
> 
> Vivien Didelot (17):
>   net: dsa: mv88e6xxx: add port mask helper
>   net: dsa: mv88e6xxx: move ATU ageing time setter
>   net: dsa: mv88e6xxx: add ATU setup helper
>   net: dsa: mv88e6xxx: setup message ports
>   net: dsa: mv88e6xxx: enable ATU Learn2All
>   net: dsa: mv88e6xxx: rework ATU Load/Purge
>   net: dsa: mv88e6xxx: rework ATU GetNext
>   net: dsa: mv88e6xxx: rework ATU Flush
>   net: dsa: mv88e6xxx: rework ATU Remove
>   net: dsa: mv88e6xxx: rename new FID helper
>   net: dsa: mv88e6xxx: rename the port vector member
>   net: dsa: add dsa_is_normal_port helper
>   net: dsa: mv88e6xxx: rework port mode setup
>   net: dsa: mv88e6xxx: fix port egress flooding mode
>   net: dsa: mv88e6xxx: add port ATU learn limit op
>   net: dsa: mv88e6xxx: add port priority override op
>   etherdevice: remove unused eth_addr_greater
> 
>  drivers/net/dsa/mv88e6xxx/Makefile      |   1 +
>  drivers/net/dsa/mv88e6xxx/chip.c        | 667 +++++++++++---------------------
>  drivers/net/dsa/mv88e6xxx/global1.h     |  11 +
>  drivers/net/dsa/mv88e6xxx/global1_atu.c | 300 ++++++++++++++
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   |  44 ++-
>  drivers/net/dsa/mv88e6xxx/port.c        |  78 +++-
>  drivers/net/dsa/mv88e6xxx/port.h        |  16 +-
>  include/linux/etherdevice.h             |  15 -
>  include/net/dsa.h                       |   5 +
>  9 files changed, 638 insertions(+), 499 deletions(-)
>  create mode 100644 drivers/net/dsa/mv88e6xxx/global1_atu.c
> 


-- 
Florian
