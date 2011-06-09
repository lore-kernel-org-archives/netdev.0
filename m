From: WeipingPan <panweiping3@gmail.com>
Subject: Re: [PATCH v4 net-next 0/5] bonding:use latest lacp_rate and ad_select,
Date: Thu, 09 Jun 2011 15:13:14 +0800
Message-ID: <4DF0728A.9010702@gmail.com>
References: <cover.1307601948.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1307601948.git.panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/09/2011 03:03 PM, Weiping Pan wrote:
> There is bug that when you modify lacp_rate via sysfs,
> 802.3ad won't use the new value of lacp_rate to transmit packets.
> This is because port->actor_oper_port_state isn't changed.
>
> As for ad_select, it can work,
> but both struct bond_params and ad_bond_info have lacp_fast and ad_select,
> they are duplicate and need extra synchronization.
> 802.3ad can get them from bond_params directly every time.
>
> And ad_timer and arp_mon_pt aren't used any more, just delete them.
>
> changelog:
> v2:
> add bond_3ad_update_lacp_rate() as a helper function,
> and hold bond->lock when iterates slave list.
>
> v3:
> delete duplicate lacp_fast and agg_select_mode from struct ad_bond_info.
>
> v4:
> delete unused ad_timer and arp_mon_pt.
>
> Weiping Pan (5):
>    bonding: make 802.3ad use latest lacp_rate
>    bonding:delete lacp_fast from ad_bond_info
>    bonding:delete agg_select_mode from ad_bond_info
>    bonding: delete unused ad_timer
>    bonding: delete unused arp_mon_pt
>
>   drivers/net/bonding/bond_3ad.c   |   41 ++++++++++++++++++++++++++++++++-----
>   drivers/net/bonding/bond_3ad.h   |    8 +-----
>   drivers/net/bonding/bond_main.c  |    3 +-
>   drivers/net/bonding/bond_sysfs.c |    1 +
>   drivers/net/bonding/bonding.h    |    1 -
>   5 files changed, 39 insertions(+), 15 deletions(-)
>
Oh, my god, it's messy, I will resend the patch set.
sorry

Weiping Pan
