From: "D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name>
Subject: Re: [RFC] bridge: MAC learning uevents
Date: Fri, 9 Sep 2016 10:51:31 +0200
Message-ID: <63AE46DA-1F36-426E-A1D4-AF95E7646177@herrendoerfer.name>
References: <7824e091-6b1a-bf39-0f78-1c9084d59972@herrendoerfer.name> <20160908083920.0d421951@xeon-e3> <F1E0DECE-4C8F-487A-B1CD-B3ADFD8DC1B1@herrendoerfer.name> <9f5db5b9-37dc-91c0-70e2-38644cc5bdb7@gmail.com> <20160908141626.0ae9025a@xeon-e3>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dd20738.kasserver.com ([85.13.140.210]:47239 "EHLO
        dd20738.kasserver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbcIIIvf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 04:51:35 -0400
In-Reply-To: <20160908141626.0ae9025a@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On Thu, 8 Sep 2016 11:30:08 -0700
> Florian Fainelli <f.fainelli@gmail.com> wrote:
> 
>> On 09/08/2016 10:19 AM, D. Herrendoerfer wrote:
>>> 
>>> On 08 Sep 2016, at 17:39, Stephen Hemminger <stephen@networkplumber.org> wrote:
>>> 
>>>> On Thu, 8 Sep 2016 15:06:16 +0200
>>>> "D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name> wrote:
>>>> 
>>>>> Hello,
>>>>> 
>>>>> I'd like to start a discussion if it makes sense to add an optional feature
>>>>> 
>>>>> to the bridge MAC address learning code to generate kernel uevents for  
>>> 
>>> [SNIP]
>>> 
>>>>> 
>>>>> I'm porting my patch (for 3.10.0) to head, and will make it available, I 
>>>>> just want some
>>>>> 
>>>>> valuable feedback as early as possible.
>>>>> 
>>>>> 
>>>>> Thanks, D.Herrendoerfer  
>>>> 
>>>> This should be possible by listening for netlink events.
>>>> No need for udev interaction.  
>>> 
>>> No, there are none, not for changes to the bridge forwarding table, also this would 
>>> require a tool to continuously listen for changes.  
>> 
>> Wat do you expect uevent to solve here that netlink + a monitoring
>> program can't?
>> 
>> There is quite a bit of code in net/bridge/br_fdb.c just to deal with
>> notifying learned/added MAC addresses, is not that where you should
>> start adding what you are after (if that is not supported as of latest
>> mainline)?
> 
> just like neighbor table modifications, it should be possible to listen for
> events with netlink. Doing it through uevent is the wrong model.

I agree partially - but consider:
we plug hardware - we get an event
we remove hardware - we get an event
we add a virtual interface - we get an event
we add a bridge - event
we add an interface to that bridge - event 
a kvm guest starts using the interface on that bridge - we need to monitor netlink, poll brforward, capture traffic

It seems inconsistent, bridge is already emitting events.
