From: Patrick Talbert <ptalbert@redhat.com>
Subject: Re: [PATCH net-next 1/1] [net] bonding: Add NUMA notice
Date: Mon, 9 Oct 2017 15:00:58 -0400
Message-ID: <CAPRrrxVFof1C6ch1uV5hA2tn+kvNiyiHZ_ygEcpdnSA-La-fSw@mail.gmail.com>
References: <1507235025-21689-1-git-send-email-ptalbert@redhat.com> <20171007.232036.1361815658002685993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:43919 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754678AbdJITBU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 15:01:20 -0400
Received: by mail-lf0-f54.google.com with SMTP id a16so10974530lfk.0
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 12:01:19 -0700 (PDT)
In-Reply-To: <20171007.232036.1361815658002685993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 7, 2017 at 6:20 PM, David Miller <davem@davemloft.net> wrote:
> From: Patrick Talbert <ptalbert@redhat.com>
> Date: Thu,  5 Oct 2017 16:23:45 -0400
>
>> Network performance can suffer when a load balancing bond uses slave
>> interfaces which are in different NUMA domains.
>>
>> This compares the NUMA domain of a newly enslaved interface against any
>> existing enslaved interfaces and prints a warning if they do not match.
>>
>> Signed-off-by: Patrick Talbert <ptalbert@redhat.com>
>
> This is a bit over the top, and doesn't even handle cases where
> the device has no specific NUMA node (-1).

Hello David,

The motivation was simply to have a notification in place if the
interface to-be-enslaved does not match the existing one(s). We have
seen performance issues with bonding which were eventually tracked
down to this mismatched NUMA domain issue. I thought it was worth
having the *mild* warning because it can have a decent impact yet is
probably not an obvious thing to check for most users.

Though I now see your point. If the bonded interfaces are VLANs, and
their underlying physical interfaces happen to be in different NUMA
domains, then my check will not know as the VLAN interface numa_node
member will be -1 no matter what. That's probably a pretty common
setup but adding the logic to check for it probably isn't worth it.

Patrick
