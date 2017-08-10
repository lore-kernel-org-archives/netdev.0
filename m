From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH RFC net-next] net: Allow name change of IFF_UP interfaces
Date: Thu, 10 Aug 2017 10:55:01 -0600
Message-ID: <88b507b7-1b60-5100-3e31-b68263f0f631@gmail.com>
References: <20170810141358.GD24790@lunn.ch>
 <87lgmrsawo.fsf@vitty.brq.redhat.com> <20170810162722.GH24790@lunn.ch>
 <20170810.094803.1621536453262110983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: vkuznets@redhat.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, edumazet@google.com,
        stephen@networkplumber.org
To: David Miller <davem@davemloft.net>, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37555 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752829AbdHJQzD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 12:55:03 -0400
Received: by mail-pg0-f68.google.com with SMTP id 83so1046868pgb.4
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 09:55:03 -0700 (PDT)
In-Reply-To: <20170810.094803.1621536453262110983.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/10/17 10:48 AM, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Thu, 10 Aug 2017 18:27:22 +0200
> 
>> On Thu, Aug 10, 2017 at 05:24:55PM +0200, Vitaly Kuznetsov wrote:
>>> Andrew Lunn <andrew@lunn.ch> writes:
>>>
>>>>> We are - rtnetlink_event() does the job. We, however, don't have a
>>>>> special IFLA_EVENT_* for name change and end up with IFLA_EVENT_NONE.
>>>>
>>>> What is in this event? Old and new name? Just the new name?
>>>
>>> Basically, it's everything we know about the interface - type, index,
>>> name, mtu, qdisc, ... - see rtnl_fill_ifinfo(). Back to your question -
>>> it's only the new name.
>>
>> So the program needs to keep track of ifindex to know which interface
>> has changed name. Doable.
>>
>> I still expect this has the potential to break something. You probably
>> should be asking on linux-api for the API experts opinion.
> 
> But a greater point is that nobody is monitoring device renames
> explicitly right now.

Just to throw in an example:
  https://github.com/kobolabs/dhcpcd/blob/kobo/if-linux.c#L761

Learned of its use from a recent regression:
https://bugzilla.kernel.org/show_bug.cgi?id=196355
