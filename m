From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH v4] bridge: netlink: check vlan_default_pvid range
Date: Wed, 17 May 2017 18:12:23 +0200
Message-ID: <20170517161223.GA13305@bistromath.localdomain>
References: <20170517072912.13063-1-tobias.jungel@bisdn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tobias Jungel <tobias.jungel@bisdn.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50512 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753785AbdEQQM1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 12:12:27 -0400
Content-Disposition: inline
In-Reply-To: <20170517072912.13063-1-tobias.jungel@bisdn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-05-17, 09:29:12 +0200, Tobias Jungel wrote:
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

Acked-by: Sabrina Dubroca <sd@queasysnail.net>


Thanks,

-- 
Sabrina
