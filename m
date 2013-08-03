From: David Miller <davem@davemloft.net>
Subject: Re: [net] net_sched: make dev_trans_start return vlan's real dev
 trans_start
Date: Sat, 03 Aug 2013 11:52:28 -0700 (PDT)
Message-ID: <20130803.115228.1509916868029010372.davem@davemloft.net>
References: <1375542471-22739-1-git-send-email-nikolay@redhat.com>
	<20130803170733.GA10218@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	jhs@mojatatu.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52248 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab3HCSwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 14:52:31 -0400
In-Reply-To: <20130803170733.GA10218@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Sat, 3 Aug 2013 19:07:33 +0200

> On Sat, Aug 03, 2013 at 05:07:51PM +0200, nikolay@redhat.com wrote:
> ...snip...
>>+	while (is_vlan_dev(dev))
>>+		dev = vlan_dev_real_dev(dev);
> 
> While at it - I've checked a few users (mainly network drivers) of
> vlan_dev_real_dev(dev) and they all rely on that the return device
> would be the *real* device, but not another vlan.

Did you find any cases that want the device under the VLAN,
whether it is a non-vlan device or not?

> So maybe we should move this while loop to vlan_dev_real_dev()
> instead?

Perhaps.  As per above, we may also need the one-level demux
helper too, something like "vlan_dev_slave(dev)".
