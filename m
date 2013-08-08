From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v1 0/6] bonding: remove bond->vlan_list
Date: Thu, 8 Aug 2013 12:39:09 +0200
Message-ID: <20130808103909.GS22756@redhat.com>
References: <1375957269-13100-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965156Ab3HHKkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 06:40:16 -0400
Content-Disposition: inline
In-Reply-To: <1375957269-13100-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 08, 2013 at 12:21:03PM +0200, Veaceslav Falico wrote:
>RFC -> v1: Got some feedback from Nikolay Aleksandrov (privately), tried to
>	   address it, also fixed some bugs that I've found on the way. I
>	   think it's ready to be considered a patchset for
>	   review/inclusion in net-next.

I've re-sent the 1/6 (with v2), got the old version from the wrong git
branch.

>
>The aim of this patchset is to remove bond->vlan_list completely, and use
>8021q's standard functions instead of it.
>
>The patchset is on top of Nik's latest two patches:
>[net-next,v2,1/2] bonding: change the bond's vlan syncing functions with
>			   the standard ones
>[net-next,v2,2/2] bonding: unwind on bond_add_vlan failure
>
>
>First two patches add two helper functions to vlan code:
>
>bonding: add rcu to vlan_uses_dev() and make bond_vlan_used() use it
>
>	Here we change vlan_uses_dev() to be able to work under both rtnl
>	and rcu, and use it under rcu_read_lock() in bond_vlan_used().
>
>vlan: add __vlan_find_dev_next()
>
>	This function takes dev and vlan_dev and returns the next vlan dev
>	that uses this dev. It can be used to cycle through the vlan list,
>	and not only by bonding - but by any network driver that uses its
>	private vlan list.
>
>Next four patches actually convert bonding to use the new
>functions/approach and remove the vlan_list completely.
>
>This patchset solves several issues with bonding, simplify it overall,
>RCUify further and add infrastructure to anyone else who'd like to use
>8021q standard functions instead of their own vlan_list, which is quite
>common amongst network drivers currently.
>
>I'm testing it continuously currently, no issues found, will update on
>anything.
>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>CC: Patrick McHardy <kaber@trash.net>
>CC: "David S. Miller" <davem@davemloft.net>
>CC: Nikolay Aleksandrov <nikolay@redhat.com>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>
>---
> drivers/net/bonding/bond_alb.c  |   48 ++++++++----
> drivers/net/bonding/bond_alb.h  |    2 +-
> drivers/net/bonding/bond_main.c |  163 ++++++---------------------------------
> drivers/net/bonding/bonding.h   |   16 ++--
> include/linux/if_vlan.h         |    8 ++
> net/8021q/vlan.h                |    6 +-
> net/8021q/vlan_core.c           |   36 ++++++++-
> 7 files changed, 115 insertions(+), 164 deletions(-)
