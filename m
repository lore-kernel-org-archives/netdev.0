From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 03/17] net: ethtool: add new
 ETHTOOL_GSETTINGS/SSETTINGS API
Date: Tue, 01 Dec 2015 22:13:56 -0500 (EST)
Message-ID: <20151201.221356.2176806670215219133.davem@davemloft.net>
References: <1448921155-24764-1-git-send-email-ddecotig@gmail.com>
	<1448921155-24764-4-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, amirv@mellanox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org, linux-mips@linux-mips.org,
	fcoe-devel@open-fcoe.org, edumazet@google.com,
	eugenia@mellanox.co.il, ogerlitz@mellanox.com, idos@mellanox.com,
	joe@perches.com, saeedm@mellanox.com, _govind@gmx.com,
	VenkatKumar.Duvvuru@Emulex.Com, jeffrey.t.kirsher@intel.com,
	eyalpe@mellanox.com, pshelar@nicira.com,
	eswierk@skyportsystems.com, robert.w.love@intel.com,
	JBottomley@parallels.com, Yuval.Mintz@qlogic.com,
	decot@googlers.com
To: ddecotig@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448921155-24764-4-git-send-email-ddecotig@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <ddecotig@gmail.com>
Date: Mon, 30 Nov 2015 14:05:41 -0800

> This patch defines a new ETHTOOL_GSETTINGS/SSETTINGS API, handled by
> the new get_ksettings/set_ksettings callbacks. This API provides
> support for most legacy ethtool_cmd fields, adds support for larger
> link mode masks (up to 4064 bits, variable length), and removes
> ethtool_cmd deprecated fields (transceiver/maxrxpkt/maxtxpkt).

Please do not define the mask using a non-fixed type.  I know it makes
it easier to use the various bitmap helper routines if you use 'long',
but here it is clearly superior to use "u32" for the bitmap type and
do the bit operations by hand if necessary.

Otherwise you have to have all of this ulong size CPP conditional code
which is incredibly ugly.

Furthermore you have to use fixed sized types anyways so that we don't
need compat code to deal with 32-bit userspace applications making
these ethtool calls into a 64-bit kernel.

THanks.
