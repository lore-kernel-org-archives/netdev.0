From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] [net] bonding: Add NUMA notice
Date: Fri, 06 Oct 2017 11:08:08 -0700
Message-ID: <1507313288.14419.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1507235025-21689-1-git-send-email-ptalbert@redhat.com>
         <20171005214636.GM13247@lunn.ch>
         <CAPRrrxUGMpOqEA8MxzY91RyMTQp+OisO8xB5jVR+QA+dqLeSww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
To: Patrick Talbert <ptalbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:47500 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752534AbdJFSIL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 14:08:11 -0400
Received: by mail-pf0-f182.google.com with SMTP id u12so9920408pfl.4
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 11:08:11 -0700 (PDT)
In-Reply-To: <CAPRrrxUGMpOqEA8MxzY91RyMTQp+OisO8xB5jVR+QA+dqLeSww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-10-06 at 13:54 -0400, Patrick Talbert wrote:

> 
> My goal with the patch is not to prevent some one from bonding
> whichever interfaces they want, only to notify them that what they are
> doing is *likely* to be less than ideal from a performance
> perspective. Even if some theoretical load balancing bonding mode was
> intelligent enough to consider NUMA when choosing a transmit
> interface, it never has control over the interface traffic is received
> on (excluding the strange balance-alb mode).

Note that following the NUMA node of current process would lead to
reordering for TCP flows.

XPS makes sure we stick to one TXQ to avoid reorders.

I am not sure your patch will really help, since you do not warn if a
process from another NUMA node tries to send packet to a bonding driver
using slaves on another NUMA node.
