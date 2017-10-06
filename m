From: Patrick Talbert <ptalbert@redhat.com>
Subject: Re: [PATCH net-next 1/1] [net] bonding: Add NUMA notice
Date: Fri, 6 Oct 2017 13:54:44 -0400
Message-ID: <CAPRrrxUGMpOqEA8MxzY91RyMTQp+OisO8xB5jVR+QA+dqLeSww@mail.gmail.com>
References: <1507235025-21689-1-git-send-email-ptalbert@redhat.com> <20171005214636.GM13247@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:44763 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751862AbdJFRzG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 13:55:06 -0400
Received: by mail-lf0-f45.google.com with SMTP id l196so21245711lfl.1
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 10:55:06 -0700 (PDT)
In-Reply-To: <20171005214636.GM13247@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 5, 2017 at 5:46 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Thu, Oct 05, 2017 at 04:23:45PM -0400, Patrick Talbert wrote:
>> Network performance can suffer when a load balancing bond uses slave
>> interfaces which are in different NUMA domains.
>>
>> This compares the NUMA domain of a newly enslaved interface against any
>> existing enslaved interfaces and prints a warning if they do not match.
>
> Hi Patrick
>
> Is there a bonding mode which might actually want to do this? Send on
> the local domain, unless it is overloaded, in which case send it to
> the other domain?
>

I suppose there could theoretically be a bonding mode that could do
that, but currently no such mode exists.

> There is also this talk for netdev:
>
> https://netdevconf.org/2.2/session.html?shochat-devicemgmt-talk

>From reading the abstract there, it sounds like such a device driver
would want to abstract away the numa location of the underlying
devices from the "unified" net device it presents to the kernel.

>
>         Andrew


My goal with the patch is not to prevent some one from bonding
whichever interfaces they want, only to notify them that what they are
doing is *likely* to be less than ideal from a performance
perspective. Even if some theoretical load balancing bonding mode was
intelligent enough to consider NUMA when choosing a transmit
interface, it never has control over the interface traffic is received
on (excluding the strange balance-alb mode).

Patrick
