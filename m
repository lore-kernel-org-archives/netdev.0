From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] vlan: slight optimization for vlan
Date: Tue, 04 Mar 2014 07:50:05 -0800
Message-ID: <1393948205.20435.28.camel@joe-AO722>
References: <5315AF42.8030905@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0111.hostedemail.com ([216.40.44.111]:37419 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753010AbaCDPuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 10:50:12 -0500
In-Reply-To: <5315AF42.8030905@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-04 at 18:47 +0800, Ding Tianhong wrote:
> Ether_addr_equal_64bits is more efficient than ether_addr_equal, and
> can be used when each argument is an array within a structure that
> contains at least two bytes of data beyond the array, so it is safe
> to use it for vlan.

Perhaps I wasn't clear or perhaps you simply disagree,
(which is certainly your right), but I think that
ether_addr_equal_64bits should _only_ be used in
performance sensitive paths because using it requires
a person/script to analyze surrounding structures to
ensure 2 bytes exist after the address.

I don't think that vlan_dev_(open|stop|set_mac_address)
are performance sensitive paths.

vlan_do_receive, absolutely yes.

Is the vlan_device_event:NETDEV_CHANGEADDR:vlan_sync_address
path that frequent?  Maybe.

> On a simple test by iperf, it reduces the CPU %system time from 14% to 12%.

> According Joe's suggestion, maybe it'd be faster to add an unlikely to
> the test for PCKET_OTHERHOST, so I add it and see whether the performance
> could be better, but the differences is so small and negligible, maybe my
> test case is not effective enough, but I still add the unlikely and wait to
> hear more opinions.:)

A separate patch for the unlikely would likely be better,
but I wonder what your test case is.

I presume a single stream of identical vlan PACKET_OTHERHOST
packets is atypical.
