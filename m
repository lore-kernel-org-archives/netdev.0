From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH RFC net-next] net: Allow name change of IFF_UP interfaces
Date: Fri, 11 Aug 2017 11:01:32 +0200
Message-ID: <87shgyqxzn.fsf@vitty.brq.redhat.com>
References: <20170810141358.GD24790@lunn.ch>
        <87lgmrsawo.fsf@vitty.brq.redhat.com> <20170810162722.GH24790@lunn.ch>
        <20170810.094803.1621536453262110983.davem@davemloft.net>
        <88b507b7-1b60-5100-3e31-b68263f0f631@gmail.com>
        <20170810101619.15142772@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ahern <dsahern@gmail.com>,
        David Miller <davem@davemloft.net>, andrew@lunn.ch,
        eric.dumazet@gmail.com, netdev@vger.kernel.org, edumazet@google.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54490 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751416AbdHKJBg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 05:01:36 -0400
In-Reply-To: <20170810101619.15142772@xeon-e3> (Stephen Hemminger's message of
        "Thu, 10 Aug 2017 10:16:19 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Thu, 10 Aug 2017 10:55:01 -0600
> David Ahern <dsahern@gmail.com> wrote:
>
>> On 8/10/17 10:48 AM, David Miller wrote:
>> > From: Andrew Lunn <andrew@lunn.ch>
>> > Date: Thu, 10 Aug 2017 18:27:22 +0200
>> >   
>> >> On Thu, Aug 10, 2017 at 05:24:55PM +0200, Vitaly Kuznetsov wrote:  
>> >>> Andrew Lunn <andrew@lunn.ch> writes:
>> >>>  
>> >>>>> We are - rtnetlink_event() does the job. We, however, don't have a
>> >>>>> special IFLA_EVENT_* for name change and end up with IFLA_EVENT_NONE.  
>> >>>>
>> >>>> What is in this event? Old and new name? Just the new name?  
>> >>>
>> >>> Basically, it's everything we know about the interface - type, index,
>> >>> name, mtu, qdisc, ... - see rtnl_fill_ifinfo(). Back to your question -
>> >>> it's only the new name.  
>> >>
>> >> So the program needs to keep track of ifindex to know which interface
>> >> has changed name. Doable.
>> >>
>> >> I still expect this has the potential to break something. You probably
>> >> should be asking on linux-api for the API experts opinion.  
>> > 
>> > But a greater point is that nobody is monitoring device renames
>> > explicitly right now.  
>> 
>> Just to throw in an example:
>>   https://github.com/kobolabs/dhcpcd/blob/kobo/if-linux.c#L761
>> 
>> Learned of its use from a recent regression:
>> https://bugzilla.kernel.org/show_bug.cgi?id=196355
>
> Quagga is another example of what might break. Especially with all the new
> forks..

I see,

even if we don't see right away why the limitation was imposed and who
depends on this 'UP interfaces keep their names' semantics it may not be
worth it to open this pandora box just because of the netvsc driver
change...

-- 
  Vitaly
