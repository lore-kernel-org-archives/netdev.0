From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnetlink: fix userspace API breakage for iproute2
 < v3.9.0
Date: Fri, 30 May 2014 17:42:48 -0700 (PDT)
Message-ID: <20140530.174248.715408523447246496.davem@davemloft.net>
References: <1401279319-29088-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	alexander.h.duyck@intel.com, michael.riesch@omicron.at
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934638AbaEaAmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 20:42:49 -0400
In-Reply-To: <1401279319-29088-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Wed, 28 May 2014 14:15:19 +0200

> When running RHEL6 userspace on a current upstream kernel, "ip link"
> fails to show VF information.
> 
> The reason is a kernel<->userspace API change introduced by commit
> 88c5b5ce5cb57 ("rtnetlink: Call nlmsg_parse() with correct header length"),
> after which the kernel does not see iproute2's IFLA_EXT_MASK attribute
> in the netlink request.
> 
> iproute2 adjusted for the API change in its commit 63338dca4513
> ("libnetlink: Use ifinfomsg instead of rtgenmsg in rtnl_wilddump_req_filter").
> 
> The problem has been noticed before:
> http://marc.info/?l=linux-netdev&m=136692296022182&w=2
> (Subject: Re: getting VF link info seems to be broken in 3.9-rc8)
> 
> We can do better than tell those with old userspace to upgrade. We can
> recognize the old iproute2 in the kernel by checking the netlink message
> length. Even when including the IFLA_EXT_MASK attribute, its netlink
> message is shorter than struct ifinfomsg.
> 
> With this patch "ip link" shows VF information in both old and new
> iproute2 versions.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

The userspace tool should be fixed on the system, rather than having the
kernel cater to a user tool bug.

I'm not applying this, sorry.
