From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] bridge: netlink: check vlan_default_pvid range
Date: Thu, 18 May 2017 10:15:23 -0400 (EDT)
Message-ID: <20170518.101523.630814087615670528.davem@davemloft.net>
References: <20170517072912.13063-1-tobias.jungel@bisdn.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, nikolay@cumulusnetworks.com,
        stephen@networkplumber.org, netdev@vger.kernel.org
To: tobias.jungel@bisdn.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43238 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756053AbdEROPZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:15:25 -0400
In-Reply-To: <20170517072912.13063-1-tobias.jungel@bisdn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Jungel <tobias.jungel@bisdn.de>
Date: Wed, 17 May 2017 09:29:12 +0200

> Currently it is allowed to set the default pvid of a bridge to a value
> above VLAN_VID_MASK (0xfff). This patch adds a check to br_validate and
> returns -EINVAL in case the pvid is out of bounds.
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
> 
> Fixes: 0f963b7592ef ("bridge: netlink: add support for default_pvid")
> Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Tobias Jungel <tobias.jungel@bisdn.de>

Applied and queued up for -stable, thank you.
