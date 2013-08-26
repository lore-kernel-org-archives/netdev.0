From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v2 0/6] bonding: remove bond->vlan_list
Date: Mon, 26 Aug 2013 18:31:54 +0200
Message-ID: <20130826163154.GF1992@redhat.com>
References: <1375981079-2936-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34256 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998Ab3HZQeK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 12:34:10 -0400
Content-Disposition: inline
In-Reply-To: <1375981079-2936-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 08, 2013 at 06:57:53PM +0200, Veaceslav Falico wrote:
>RFC -> v1: Got some feedback from Nikolay Aleksandrov (privately), tried to
>	   address it, also fixed some bugs that I've found on the way. I
>	   think it's ready to be considered a patchset for
>	   review/inclusion in net-next.
>
>v1  -> v2: Remove ASSERT_RTNL() from vlan_uses_dev(), cause it can be
>	   already called under rcu, without rtnl. Don't check for master
>	   device in __vlan_find_dev_next(), otherwise we won't be able to
>	   work in situations when a device has both vlans and master
>	   device. Properly init vlan_dev in bond_has_this_ip() before
>	   using (sigh). There was a proposal of making a macro
>	   "dev_for_each_vlan_from(dev, vlan_dev, i, from)", which would
>	   use __vlan_find_dev_deep() inside, with its strong and weak
>	   parts, but I've decided to stick to the "while (dev = next())"
>	   scheme currently - it might be added anytime, and now the only
>	   user (bonding) doesn't really need it.

I've taken a different (less intrusive for non-bonding stuff) approach on
the issue, so sent the new patchset not as a v3, but as a standalone one:

[PATCH net-next 0/8] bonding: remove vlan special handling

Thanks all for the help.
