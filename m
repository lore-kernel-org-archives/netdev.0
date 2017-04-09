From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3 iproute] ip: Add support for netdev events to monitor
Date: Sat, 8 Apr 2017 22:54:07 -0400
Message-ID: <1cc68cb4-c4be-a399-b0ed-8179d27c1b6e@cumulusnetworks.com>
References: <1491312333-18904-1-git-send-email-vyasevic@redhat.com>
 <0a7efd86-3345-223a-7a39-8c8cd1a42f14@cumulusnetworks.com>
 <20170408.193311.1975315968848220462.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34123 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751150AbdDICyK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 22:54:10 -0400
Received: by mail-pf0-f169.google.com with SMTP id c198so8138796pfc.1
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 19:54:10 -0700 (PDT)
In-Reply-To: <20170408.193311.1975315968848220462.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/17 10:33 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Sat, 8 Apr 2017 18:24:06 -0400
> 
>> per comments on the email thread about reducing notifications, the
>> kernel patch for this should be reverted (and hence this iproute2 patch
>> is not needed) in favor of using a bitmask. Right now there are too many
>> redundant notifications to userspace.
> 
> I must have missed something in all the discussion, which patch needs
> to be reverted from my tree exactly?
> 

Here's the thread:
https://www.spinics.net/lists/netdev/msg429154.html

The comment is that def12888c161 is adding a uapi that leads to way too
many notifications (e.g., on a setlink).

It would be more efficient (read less notifications) to have do_setlink
emit a single message with the IFLA_EVENT (or something else
appropriately named) that indicates what attributes changed. Right now,
a change MTU leads to 3 notifications causing unnecessary churn in
userspace to track what the state of the link is.
