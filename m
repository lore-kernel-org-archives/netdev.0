From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next V3 2/2] rtnl: Add support for netdev event
 attribute to link messages
Date: Mon, 1 May 2017 09:35:21 -0400
Message-ID: <00ddfbb9-9cf7-026d-562b-1b7a4a7129d3@redhat.com>
References: <1492795881-11914-1-git-send-email-vyasevic@redhat.com>
 <1492795881-11914-3-git-send-email-vyasevic@redhat.com>
 <877efb54-2aef-4d1e-c0b4-2ce6aa6562df@cumulusnetworks.com>
 <7b5396ae-0cf3-2a1e-9c49-5d6f031adf58@redhat.com>
 <760db30a-859a-a365-e0f3-69a4433ef9bf@cumulusnetworks.com>
 <20170428163804.GH1886@nanopsycho.orion>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
        roopa <roopa@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>,
        David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35464 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1424272AbdEANfY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 09:35:24 -0400
In-Reply-To: <20170428163804.GH1886@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/28/2017 12:38 PM, Jiri Pirko wrote:
> Thu, Apr 27, 2017 at 09:59:38PM CEST, dsa@cumulusnetworks.com wrote:
>> On 4/27/17 1:43 PM, Vlad Yasevich wrote:
>>>> For example, NETDEV_CHANGEINFODATA is only for bonds though nothing
>>>> about the name suggests it is a bonding notification. This one was added
>>>> specifically to notify userspace (d4261e5650004), yet seems to happen
>>>> only during a changelink and that already generates a RTM_NEWLINK
>>>> message via do_setlink. Since the rtnetlink_event message does not
>>>> contain anything "NETDEV_CHANGEINFODATA" related what purpose does it
>>>> really serve besides duplicating netlink messages to userspace.
>>>>
>>>
>>> I am not sure about this one, but if you have an app trying to monitor
>>> for this event, it can't really since there is no info in the netlink message.
>>
>> I cc'ed Jiri on this thread hoping he would explain the intent.
>>
>> I propose it gets removed.
> 
> Hmm, I don't really recall. But looking at it now, I agree it is
> redundant.
> 

So, it looks like the notifier might be there to account for the ioctl/sysfs
interfaces.

Additionally, the message is not generated from do_setlink() if the devices is
down, so notifier accounts for that as well.

I guess, basic question is whether data carried in NETDEV_CHANGEINFODATA is useful
to user space?  If yes (I can possibly see some managements apps that might be interested
in it), then we shouldn't just remove it.  Possible solutions to eliminate duplicates
would be to move the notifier call into non-rtnl code paths...

Also, may be netdev_state_change() should call rtmsg_ifinfo() unconditionally?

-vlad
