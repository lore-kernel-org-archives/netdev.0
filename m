From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net-next] net: Allow name change of IFF_UP
 interfaces
Date: Thu, 10 Aug 2017 09:48:03 -0700 (PDT)
Message-ID: <20170810.094803.1621536453262110983.davem@davemloft.net>
References: <20170810141358.GD24790@lunn.ch>
        <87lgmrsawo.fsf@vitty.brq.redhat.com>
        <20170810162722.GH24790@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vkuznets@redhat.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, edumazet@google.com,
        stephen@networkplumber.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33174 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753319AbdHJQsF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 12:48:05 -0400
In-Reply-To: <20170810162722.GH24790@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu, 10 Aug 2017 18:27:22 +0200

> On Thu, Aug 10, 2017 at 05:24:55PM +0200, Vitaly Kuznetsov wrote:
>> Andrew Lunn <andrew@lunn.ch> writes:
>> 
>> >> We are - rtnetlink_event() does the job. We, however, don't have a
>> >> special IFLA_EVENT_* for name change and end up with IFLA_EVENT_NONE.
>> >
>> > What is in this event? Old and new name? Just the new name?
>> 
>> Basically, it's everything we know about the interface - type, index,
>> name, mtu, qdisc, ... - see rtnl_fill_ifinfo(). Back to your question -
>> it's only the new name.
> 
> So the program needs to keep track of ifindex to know which interface
> has changed name. Doable.
> 
> I still expect this has the potential to break something. You probably
> should be asking on linux-api for the API experts opinion.

But a greater point is that nobody is monitoring device renames
explicitly right now.

It's hard to legitimize imposing new requirements like this on daemons
which didn't exist before.

If they could assume the name didn't change, they probably are doing
so.

You can't expect that just because they might already be listening to
this event for device up and down tracking that they are handling
device renames.
