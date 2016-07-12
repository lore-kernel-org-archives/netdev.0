From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: ethtool TODO list - additional info
Date: Tue, 12 Jul 2016 11:25:15 -0700
Message-ID: <5785360B.50600@gmail.com>
References: <CAPfrtUew6TKRMhoBfQ6MjxrCOsiQTYmM-2b20961LyRcLMOSZw@mail.gmail.com>
 <20160712175558.GB1799@nanopsycho.orion>
 <CAPfrtUcAuu5t7xQ-F4d-+AAbSByOzD7aBa_+UsE_xoXRdxEuoA@mail.gmail.com>
 <20160712181251.GA22464@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>,
	Jorge Alberto Garcia <jorge.garcia.gonzalez@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33651 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbcGLSZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 14:25:28 -0400
Received: by mail-pf0-f178.google.com with SMTP id i123so9332574pfg.0
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 11:25:27 -0700 (PDT)
In-Reply-To: <20160712181251.GA22464@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-12 11:12 AM, John W. Linville wrote:
> On Tue, Jul 12, 2016 at 01:04:52PM -0500, Jorge Alberto Garcia wrote:
>> On Tue, Jul 12, 2016 at 12:55 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Tue, Jul 05, 2016 at 05:37:42PM CEST, jorge.garcia.gonzalez@gmail.com wrote:
>>>> Hi !
>>>>
>>>> Some days ago, Jiri Pirko was talking about some next steps to
>>>> implement for ethtool.
>>>>
>>>> I haven't seen any follow up since ethtool's maintainer change. Can we have
>>>> additional details about these ?
>>>>
>>>> - libethtool - API
>>>> - generic netlink
>>>
>>> Yep, exactly, no reply. Apparently nobody really want to do any initiative
>>> here, and I'm lacking time to do it :(
>>>
>>
>> That's fine,  I already got  a git repo, I'm trying to understand what
>> 'use generic netlink' means.
>>
>> This is a piece of what grep got me on iproute git repo (I'm still
>> trying to understand)
>> grep -i netlink -r iproute2/
>> iproute2/bridge/mdb.c:#include "libnetlink.h"
>> iproute2/bridge/vlan.c:#include "libnetlink.h"
>> ...
>> ..
> 
> The general notion would be to replace the current ioctl-based
> ethtool API with one that is based on netlink, like many of the other
> networking APIs. I'm fine with the general idea of that, but so far
> I haven't heard a strong case for why it is necessary. It certainly
> doesn't seem urgent to me -- if someone disagrees, then please explain!
> 

And probably obvious but you can't remove the ioctl based ethtool
interface because we have a lot of software using it so you will have
to maintain both in parallel if there is a netlink equivalent.

Also most the stuff in ethtool tends to be things you set once at
init time or for debugging so the benefit of notifiers and such are
minimal.

Sure if I was doing it from scratch netlink would be better and there
are probably parts of it that are worth converting over where notifier
hooks and standardizing would be beneficial. I think Roopa for example
was coming up with some more general statistics mechanism.

My $.02 anyways.

JohnF
