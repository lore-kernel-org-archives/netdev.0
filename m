From: David Decotigny <ddecotig@gmail.com>
Subject: Re: [PATCH net-next v8 05/19] net: ethtool: add new
 ETHTOOL_GSETTINGS/SSETTINGS API
Date: Thu, 18 Feb 2016 11:49:55 -0800
Message-ID: <CAG88wWZNB5bT7ywMbcfGbQS=f2gdbC6NpKVt5Opcs-oAbMUjLw@mail.gmail.com>
References: <1455064168-5102-1-git-send-email-ddecotig@gmail.com>
 <1455064168-5102-6-git-send-email-ddecotig@gmail.com> <1455328149.2801.82.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	linux-mips@linux-mips.org, fcoe-devel@open-fcoe.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>, Eric Dumazet <edumazet@google.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@emulex.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ed Swierk <eswierk@skyportsystems.com>,
	Robert Love <robert.w.love@intel.com>,
	"James E.Yuval Mintz" <Yuval.Mintz@qlogic.com>,
	Rasmus Villemoes <linu
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455328149.2801.82.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sure, I will send an update:

struct ethtool_link_settings {
        __u32   cmd;
        __u32   speed;
        __u8    duplex;
        __u8    port;
        __u8    phy_address;
        __u8    autoneg;
        __u8    mdio_support;
        __u8    eth_tp_mdix;
        __u8    eth_tp_mdix_ctrl;
        __s8    link_mode_masks_nwords;
        __u32   reserved[8];
        __u32   link_mode_masks[0];
};

(+ same renaming for the ioctl sub-cmds)

that would still replace GSET/SSET/ethtool_cmd.

would that be ok?

Or, just to make sure: would you rather keep GSET/SSET/ethtool_cmd as
now for everything but the link mode masks (that would be marked as
deprecated), and have only a new command G/SLINK_MODES + struct
ethtool_link_mode_support that would only take care of the link mode
masks?

On Fri, Feb 12, 2016 at 5:49 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Tue, 2016-02-09 at 16:29 -0800, David Decotigny wrote:
>> From: David Decotigny <decot@googlers.com>
>>
>> This patch defines a new ETHTOOL_GSETTINGS/SSETTINGS API, handled by
>> the new get_ksettings/set_ksettings callbacks. This API provides
>> support for most legacy ethtool_cmd fields, adds support for larger
>> link mode masks (up to 4064 bits, variable length), and removes
>> ethtool_cmd deprecated fields (transceiver/maxrxpkt/maxtxpkt).
> [...]
>
> I previously asked you to include 'link' in the command names and
> structure name.  This would clarify that these are now only for link
> settings and reduce the risk of confusion between old and new commands.
> However, you didn't reply to that review.  Do you have any objection to
> doing this?
>
> Ben.
>
> --
> Ben Hutchings
> Sturgeon's Law: Ninety percent of everything is crap.
