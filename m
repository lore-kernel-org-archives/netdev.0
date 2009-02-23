From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 3/8] can: CAN Network device driver and SYSFS interface
Date: Mon, 23 Feb 2009 15:57:13 +0100
Message-ID: <49A2B949.7060909@grandegger.com>
References: <1235070082-7069-1-git-send-email-wg@grandegger.com> <1235070082-7069-2-git-send-email-wg@grandegger.com> <1235070082-7069-3-git-send-email-wg@grandegger.com> <1235070082-7069-4-git-send-email-wg@grandegger.com> <499E7B9B.6030603@trash.net> <49A01932.4090004@grandegger.com> <49A272A3.5040405@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:60065 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859AbZBWO5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 09:57:16 -0500
In-Reply-To: <49A272A3.5040405@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Wolfgang Grandegger wrote:
>> Patrick McHardy wrote:
>>> Is sysfs really the best choice for this? It has the usual problems,
>>> you can't change multiple parameters at once atomically. Now, I don't
>>> know whether this is actually (and currently) a problem for CAN, but
>>> given that we already have a generic netlink interface for creating
>>> network interfaces that can easily support this, what are the reasons
>>> for adding a new interface instead of using the existing one?
>>
>> You refer to the API described at http://lwn.net/Articles/236919/, I
>> assume.
> 
> Exactly.
> 
>> Well, I know that netlink is used to define routes in the kernel
>> or VLANs but I was not aware that it can also be used to configure real
>> network devices. What a pity. At a first glance, I could also be used
>> for CAN, of course. There are the following requirements:
>>
>> 1. Set and get CAN device properties like bit-rate and controller mode.
>> 2. Show CAN bus state (active, error-passive or bus-off).
>> 3. Get device constants like clock frequency and bit-timing parameters.
>> 4. Dump CAN device statistics.
>> 5. Trigger device restart if CAN bus-off state has been detected.
>>
>> Not sure yet, if the interface if good for all purposes. Especially
>> point 5. might be better handled by an IOCTL.
> 
> The first points sound pretty regular. The last one - just triggering
> it is no problem of course, but since I don't know how the detection
> works, I can't really tell whether its suitable.

CAN errors and state changes might be delivered as CAN error messages to
the receiving socket/application, like normal messages. When the
application realizes the state change to CAN bus-off, it may want to
trigger a bus-off recovery (controller restart). The CAN controller HW
enters bus-off, when too much errors occurred on the bus. No more
messages can then be sent of received and therefore the driver calls
netif_carrier_off(). Is there already an interface for the user to
restart? An appropriate IOCTL request would be a simply option, but they
are generally deprecated, AFAIK. Using netlink would be more cumbersome,
as with SYSFS.

>> And we need a user space
>> tool, e.g. canconfig, to handle the user requests and communicate with
>> the kernel side.
> 
> Thats pretty standard :)

For the iproute2 utility "ip", mainliy a netlink_can.c would be
required. But a dedicated tool for CAN seems more appropriate to me.

>> We will follow that promising route. Any further help
>> or link is appreciated. Thanks.
> 
> It should be quite easy to move your interface on top. A few examples
> that might be useful are vlan, ip_gre and macvlan.

Also the drivers dummy and ipb are quite useful. Using netlink seems
straight-forward, indeed, but it requires still some effort. Hope to
find some time soon.

Wolfgang.


