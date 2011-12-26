From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 01/14 v2] mac802154: basic
 ieee802.15.4 device structures
Date: Mon, 26 Dec 2011 15:07:20 -0500 (EST)
Message-ID: <20111226.150720.932661578734898837.davem@davemloft.net>
References: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
	<1324918953-14813-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1324918953-14813-1-git-send-email-alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 26 Dec 2011 20:02:33 +0300

> +enum ieee802154_hw_addr_filt_flags {
> +	IEEE802515_SADDR_CHANGED	= 1 << 0,
> +	IEEE802515_IEEEADDR_CHANGED	= 1 << 1,
> +	IEEE802515_PANID_CHANGED	= 1 << 2,
> +	IEEE802515_PANC_CHANGED		= 1 << 3,
> +};

These enumeration definitions for flags are undesriable for several
reasons.

First you do not even indicate what datastructure member these flags
are used in.  And because you use an enumeration you can't just indicate
this by using "enum ieee802154_hw_addr_filt_flags" as the type in the
datastructure.

Forget all the enum crap, at the datastructure where the flags are defined
do something like:

	u32	flags;
#define IEEE802154_AFILT_SADDR_CHANGED		0x00000001
#define IEEE802154_AFILT_IEEEADDR_CHANGED	0x00000002
#define IEEE802154_AFILT_PANID_CHANGED		0x00000004
#define IEEE802154_AFILT_PANC_CHANGED		0x00000008

There is then no confusion whatsoever where these flag bits are meant
to be applied and used, and the spurious data type definition is eliminated.

------------------------------------------------------------------------------
Write once. Port to many.
Get the SDK and tools to simplify cross-platform app development. Create 
new or port existing apps to sell to consumers worldwide. Explore the 
Intel AppUpSM program developer opportunity. appdeveloper.intel.com/join
http://p.sf.net/sfu/intel-appdev
