From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: netlink: Fix multicast group storage
 allocation for families with more than one groups
Date: Tue, 12 Jan 2016 16:42:11 -0500 (EST)
Message-ID: <20160112.164211.956459588621139898.davem@davemloft.net>
References: <20160111122610.GA28615@fi-ourus-dhcp00977.emea.nsn-net.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes.berg@intel.com, jbenc@redhat.com, bywxiaobai@163.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alexander.sverdlin@nokia.com, teppo.o.pennanen@nokia.com
To: matti.vaittinen@nokia.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160111122610.GA28615@fi-ourus-dhcp00977.emea.nsn-net.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matti Vaittinen <matti.vaittinen@nokia.com>
Date: Mon, 11 Jan 2016 14:26:19 +0200

> Multicast groups are stored in global buffer. Check for needed buffer size
> incorrectly compares buffer size to first id for family. This means that
> for families with more than one mcast id one may allocate too small buffer
> and end up writing rest of the groups to some unallocated memory. Fix the 
> buffer size check to compare allocated space to last mcast id for the 
> family.
> 
> Tested on ARM using kernel 3.14
> 
> Signed-off-by: Matti Vaittinen <matti.vaittinen@nokia.com>

Indeed, it looks like this function was never tested with any value
of n_groups other than one.

But I think your change has an off-by-one bug:

> -		if (id >= mc_groups_longs * BITS_PER_LONG) {
> +		if (id + n_groups >= mc_groups_longs * BITS_PER_LONG) {

I think this needs to be "id + n_groups > ".  Consider the existing,
working, case of "n_groups == 1".  Now you're adding '1' and therefore
the test needs to be adjusted from >= to >.

Thanks.
