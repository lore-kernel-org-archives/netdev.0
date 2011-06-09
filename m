From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v4 net-next 0/5] bonding:use latest lacp_rate and ad_select and delete unused ad_timer and arp_mon_pt
Date: Thu, 09 Jun 2011 14:58:11 -0700
Message-ID: <31665.1307656691@death>
References: <cover.1307603621.git.panweiping3@gmail.com>
Cc: andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:49959 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756425Ab1FIV6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 17:58:19 -0400
In-reply-to: <cover.1307603621.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Weiping Pan <panweiping3@gmail.com> wrote:

>There is bug that when you modify lacp_rate via sysfs,
>802.3ad won't use the new value of lacp_rate to transmit packets.
>This is because port->actor_oper_port_state isn't changed.
>
>As for ad_select, it can work,
>but both struct bond_params and ad_bond_info have lacp_fast and ad_select,
>they are duplicate and need extra synchronization.
>802.3ad can get them from bond_params directly every time.
>
>And ad_timer and arp_mon_pt aren't used any more, just delete them.
>
>changelog:
>v2:
>add bond_3ad_update_lacp_rate() as a helper function,
>and hold bond->lock when iterates slave list.
>
>v3:
>delete duplicate lacp_fast and agg_select_mode from struct ad_bond_info.
>
>v4:
>delete unused ad_timer and arp_mon_pt.

	All patches in the series look reasonable.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J



>Weiping Pan (5):
>  bonding: make 802.3ad use latest lacp_rate
>  bonding:delete lacp_fast from ad_bond_info
>  bonding:delete agg_select_mode from ad_bond_info
>  bonding: delete unused ad_timer
>  bonding: delete unused arp_mon_pt
>
> drivers/net/bonding/bond_3ad.c   |   41 ++++++++++++++++++++++++++++++++-----
> drivers/net/bonding/bond_3ad.h   |    8 +-----
> drivers/net/bonding/bond_main.c  |    3 +-
> drivers/net/bonding/bond_sysfs.c |    1 +
> drivers/net/bonding/bonding.h    |    1 -
> 5 files changed, 39 insertions(+), 15 deletions(-)
>
>-- 
>1.7.4.4
>
