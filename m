From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 iproute] ip: Add support for netdev events to monitor
Date: Sun, 09 Apr 2017 14:47:21 -0700 (PDT)
Message-ID: <20170409.144721.342305587683511172.davem@davemloft.net>
References: <0a7efd86-3345-223a-7a39-8c8cd1a42f14@cumulusnetworks.com>
        <20170408.193311.1975315968848220462.davem@davemloft.net>
        <1cc68cb4-c4be-a399-b0ed-8179d27c1b6e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32838 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751307AbdDIVrY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 17:47:24 -0400
In-Reply-To: <1cc68cb4-c4be-a399-b0ed-8179d27c1b6e@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat, 8 Apr 2017 22:54:07 -0400

> On 4/8/17 10:33 PM, David Miller wrote:
>> From: David Ahern <dsa@cumulusnetworks.com>
>> Date: Sat, 8 Apr 2017 18:24:06 -0400
>> 
>>> per comments on the email thread about reducing notifications, the
>>> kernel patch for this should be reverted (and hence this iproute2 patch
>>> is not needed) in favor of using a bitmask. Right now there are too many
>>> redundant notifications to userspace.
>> 
>> I must have missed something in all the discussion, which patch needs
>> to be reverted from my tree exactly?
>> 
> 
> Here's the thread:
> https://www.spinics.net/lists/netdev/msg429154.html
> 
> The comment is that def12888c161 is adding a uapi that leads to way too
> many notifications (e.g., on a setlink).
> 
> It would be more efficient (read less notifications) to have do_setlink
> emit a single message with the IFLA_EVENT (or something else
> appropriately named) that indicates what attributes changed. Right now,
> a change MTU leads to 3 notifications causing unnecessary churn in
> userspace to track what the state of the link is.

Ok, I'll queue up the revert.  I guess this means your rtnetlink
patch set is going to need changes or a respin, therefore.
