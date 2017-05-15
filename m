From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH] bridge: netlink: check vlan_default_pvid range
Date: Mon, 15 May 2017 14:01:20 +0200
Message-ID: <20170515120120.GA13122@bistromath.localdomain>
References: <20170515110819.11847-1-tobias.jungel@bisdn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tobias Jungel <tobias.jungel@bisdn.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39382 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753875AbdEOMBj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 08:01:39 -0400
Content-Disposition: inline
In-Reply-To: <20170515110819.11847-1-tobias.jungel@bisdn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tobias,

2017-05-15, 13:08:19 +0200, Tobias Jungel wrote:
> Currently it is allowed to set the default pvid of a bridge to a value
> above VLAN_VID_MASK (0xfff). This patch checks the passed pvid and
> disables the pvid in case it is out of bounds.

Could we return an error (-EINVAL) to userspace instead?  Silently
disabling the feature seems confusing to me.  This would probably be
better in br_validate() (like the IFLA_BR_VLAN_PROTOCOL check), since
there's already such a check when setting default_pvid from sysfs (in
br_vlan_set_default_pvid()).

> 
> Reproduce by calling:
> 
> [root@test ~]# ip l a type bridge
> [root@test ~]# ip l a type dummy
> [root@test ~]# ip l s bridge0 type bridge vlan_filtering 1
> [root@test ~]# ip l s bridge0 type bridge vlan_default_pvid 9999
> [root@test ~]# ip l s dummy0 master bridge0
> [root@test ~]# bridge vlan
> port	vlan ids
> bridge0	 9999 PVID Egress Untagged
> 
> dummy0	 9999 PVID Egress Untagged

You'll also need to add a Signed-off-by, and a Fixes tag would be nice.


Thanks,

-- 
Sabrina
