From: David Miller <davem@davemloft.net>
Subject: Re: [Intel-wired-lan] [PATCH 1/2] e1000e: Don't return
 uninitialized stats
Date: Mon, 24 Apr 2017 15:15:32 -0400 (EDT)
Message-ID: <20170424.151532.982765506323365908.davem@davemloft.net>
References: <20170421212012.25950-1-bpoirier@suse.com>
        <71d8032d-5ed1-8242-83e6-16ce65718966@molgen.mpg.de>
        <20170424190151.cbmbbeyjspoolpho@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pmenzel@molgen.mpg.de, jeffrey.t.kirsher@intel.com,
        netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        s.priebe@profihost.ag
To: bpoirier@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56350 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1166655AbdDXTPg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 15:15:36 -0400
In-Reply-To: <20170424190151.cbmbbeyjspoolpho@f1.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>
Date: Mon, 24 Apr 2017 12:01:51 -0700

> On 2017/04/24 10:23, Paul Menzel wrote:
>> Dear Benjamin,
>> 
>> 
>> Thank you for your fix.
>> 
>> On 04/21/17 23:20, Benjamin Poirier wrote:
>> > Some statistics passed to ethtool are garbage because e1000e_get_stats64()
>> > doesn't write them, for example: tx_heartbeat_errors. This leaks kernel
>> > memory to userspace and confuses users.
>> 
>> Could you please give specific examples to reproduce the issue? That way
>> your fix can also be tested.
>> 
> 
> Some fields in e1000_get_ethtool_stats()'s net_stats are not initialized
> by e1000e_get_stats64(). The structure is allocated on the stack,
> therefore, the value of those fields depends on previous stack content;
> that in turns depends on kernel version, compiler and previous execution
> path.

I agree.

I read over these code paths earlier today and came to the same exact
conclusion.
