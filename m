From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [PATCH net-next v7 0/4] net: Introduce protodown flag.
Date: Wed, 15 Jul 2015 11:56:42 -0700
Message-ID: <CACcJQnQCPVt1Dq4KRCA5M4QZh18bQM4vbK49G7c9CHkCnpCM3Q@mail.gmail.com>
References: <1436906602-2958-1-git-send-email-anuradhak@cumulusnetworks.com>
	<CAE4R7bC2WPDfJiT7Av8YYUybvc0D1cakKBgDsL+mystM33guFw@mail.gmail.com>
	<CACcJQnRb89XcEy7c42aNYrvG7SHAU7Lak_+Hj2rWyVeSqpzt6A@mail.gmail.com>
	<CAE4R7bB6N-auEk8hZhVv4OxVFtPTZ63d78TF376pxPcn=mnE9g@mail.gmail.com>
	<CACcJQnTSuXERF18Bc3b2NpbkvCpVzpEBTDDU+Y5gZOS=6C4hLQ@mail.gmail.com>
	<CAE4R7bBm1udW2aRRjrHgA5413XFKOoUNwCk=5ZDtv0RQ70qE7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:33226 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084AbbGOS4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 14:56:43 -0400
Received: by laem6 with SMTP id m6so30315177lae.0
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 11:56:42 -0700 (PDT)
In-Reply-To: <CAE4R7bBm1udW2aRRjrHgA5413XFKOoUNwCk=5ZDtv0RQ70qE7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 11:46 AM, Scott Feldman <sfeldma@gmail.com> wrote:
> On Wed, Jul 15, 2015 at 11:36 AM, Anuradha Karuppiah
> <anuradhak@cumulusnetworks.com> wrote:
>> On Wed, Jul 15, 2015 at 11:29 AM, Scott Feldman <sfeldma@gmail.com> wrote:
>>> On Wed, Jul 15, 2015 at 8:53 AM, Anuradha Karuppiah
>>> <anuradhak@cumulusnetworks.com> wrote:
>>>> On Tue, Jul 14, 2015 at 10:08 PM, Scott Feldman <sfeldma@gmail.com> wrote:
>>>>> On Tue, Jul 14, 2015 at 1:43 PM,  <anuradhak@cumulusnetworks.com> wrote:
>>>>>> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>>>>>>
>>>>>> User space daemons can detect errors in the network that need to be
>>>>>> notified to the switch device drivers.
>>>>>>
>>>>>> Drivers can react to this error state by doing a phy-down on the
>>>>>> switch-port which would result in a carrier-off locally and on the directly
>>>>>> connected switch. Doing that would prevent loops and black-holes in the
>>>>>> network.
>>>>>
>>>>> Hi Anuradha,
>>>>>
>>>>> Since this is a switch-thingy, can you move this to switchdev port
>>>>> attribute rather than adding another ndo op?  I know you started this
>>>>> patch set before switchdev port attrs, but I think it's worthwhile
>>>>> moving it to switchdev since clearly the use-case is switch device
>>>>> drivers.   Let me know if you need help converting over to switchdev
>>>>> port attr.
>>>>>
>>>>> Also, is the sysfs interface necessary?  The netlink/iproute2
>>>>> interface seems sufficient.
>>>>>
>>>>> -scott
>>>>
>>>> Yes, for the current use case (MLAG) it would be better to isolate the
>>>> changes to switchdev. Also if we go with the switchdev option are you
>>>> thinking about dropping the netdev->proto_down bool attribute
>>>> altogether and only keeping that info in the switch drivers that
>>>> support the op?
>>>
>>> Yes.
>>>
>>>> You are right, the sysfs is not necessary. I can make it RO and just
>>>> use it for displaying or drop it all together. What would you
>>>> recommend?
>>>
>>> Drop it if it's not needed/used.
>>>
>>> On the iproute2 part, do we expect users to manually toggle this flag
>>> from the cmdline?  Seems kind of weird to walk up to a box and say "ip
>>> link set dev DEV protodown on".  Isn't this more intended for external
>>> agents (i.e. MLAG) to toggle?  I guess if there is a netlink attr for
>>> the flag, there should be a user-interface.  But it seems like it'll
>>> be a source of confusion for 99.999% of the users out there that
>>> wonder what this knob does.
>>
>> The MLAG app currently does use the iproute2 interface for toggling
>> protodown. So I may not be able to drop the iproute2 config option
>> easily.
>
> It can send netlink msg directly as easy as doing exec "ip link set
> ...", I assume.
>
> Forgive me if I've asked this before: where is this MLAG app?
We are in the process of making the app ready for open-sourcing and
upstreaming this patch set was part of that.
