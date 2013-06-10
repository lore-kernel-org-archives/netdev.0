From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 03/03] [PATCH] vxlan: fix crash on module removal
Date: Mon, 10 Jun 2013 14:14:21 -0700 (PDT)
Message-ID: <20130610.141421.1570141372448161465.davem@davemloft.net>
References: <20130610195822.888424947@vyatta.com>
	<20130610131315.384c5b61@nehalam.linuxnetplumber.net>
	<20130610.140114.1116004856133608655.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59884 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638Ab3FJVOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 17:14:24 -0400
In-Reply-To: <20130610.140114.1116004856133608655.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@redhat.com>
Date: Mon, 10 Jun 2013 14:01:14 -0700 (PDT)

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Mon, 10 Jun 2013 13:13:15 -0700
> 
>> If vxlan is removed with active vxlan's it would crash because
>> rtnl_link_unregister (which calls vxlan_dellink), was invoked
>> before unregister_pernet_device (which calls vxlan_stop).
>> 
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>> ---
>> Should goto stable
> 
> Applied and queued up for -stable.

Actually, this doesn't even compile.

+	destroy_workqueue(vxlan_wq);

vxlan_wq doesn't exist in the 'net' tree.

It doesn't exist in net-next either.

It gets added as part of your vxlan-next series which you posted at
the same time.

I'm tossing both vxlan patch sets, you'll need to resubmit them
properly.

I'm tossing both becuase I can tell the -next one won't apply properly
on top of this series up when you fix it up.
