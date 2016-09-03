From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] af_packet FANOUT and device dismantle
Date: Fri, 02 Sep 2016 17:37:30 -0700 (PDT)
Message-ID: <20160902.173730.771175006796901877.davem@davemloft.net>
References: <1472774683.5439.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59520 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752711AbcICAhb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 20:37:31 -0400
In-Reply-To: <1472774683.5439.8.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Sep 2016 17:04:43 -0700

> When you added fanout in commit dc99f600698dcac,
> it seems a device dismantle is not properly handled.
> 
> packet_notifier() does properly finds all sockets attached to the
> device and we call __unregister_prot_hook()
> 
> But the actual dev_remove_pack() is called when the last socket attached
> to the FANOUT group is _closed_ , possibly minutes after the device
> disappeared.
> 
> So we trigger the BUG_ON(!list_empty(&dev->ptype_all)); in
> netdev_run_todo(), that came with linux-4.0 in 
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=7866a621043fbaca3d7389e9b9f69dd1a2e5a855
> 
> Fix would be to call dev_remote_pack() from __fanout_unlink() when
> num_members becomes 0.
> 
> Let me know if you agree with this, thanks.

I completely agree with your analysis, good catch.
