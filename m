From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] openvswitch: Use regular GRE
 net_device instead of vport
Date: Mon, 03 Aug 2015 21:59:55 -0700 (PDT)
Message-ID: <20150803.215955.1031623872655808616.davem@davemloft.net>
References: <1438648046-10346-1-git-send-email-pshelar@nicira.com>
	<20150804042339.GA47032@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbbHDE74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 00:59:56 -0400
In-Reply-To: <20150804042339.GA47032@Alexeis-MBP.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Mon, 3 Aug 2015 21:23:40 -0700

> On Mon, Aug 03, 2015 at 05:27:26PM -0700, Pravin B Shelar wrote:
>> With addition of flow based tunneling, there is no need to
>> have special GRE vport. Removes all of the OVS specific
>> GRE code and make OVS use a ip_gre net_device.
>> Minimal GRE vport is kept to handle compatibility with
>> current userspace application.
>> 
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ...
>> +#define GRE_TAP_FB_NAME "gretap0"
> ...
>> +	/* fallback device is used for flow based tunneling. */
>> +	if (!strcmp(dev->name, GRE_TAP_FB_NAME)) {
>> +		struct ip_tunnel *t;
>> +
>> +		t = netdev_priv(dev);
>> +		t->flow_based_tunnel = true;
>> +		eth_hw_addr_random(dev);
>> +		netif_keep_dst(dev);
>> +	}
>> +
> 
> feature detection based on netdev name?
> meaning that there will be only one such device for the whole
> host? and namespaces cannot have their own gre tunnels?
> (since host 'gretap0' cannot be seen in netns)

Doing anything like this by netdev name is wrong.

Pravin you will need to do this in some other way.
