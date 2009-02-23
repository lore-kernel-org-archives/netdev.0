From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/8] can: CAN Network device driver and SYSFS interface
Date: Mon, 23 Feb 2009 10:55:47 +0100
Message-ID: <49A272A3.5040405@trash.net>
References: <1235070082-7069-1-git-send-email-wg@grandegger.com> <1235070082-7069-2-git-send-email-wg@grandegger.com> <1235070082-7069-3-git-send-email-wg@grandegger.com> <1235070082-7069-4-git-send-email-wg@grandegger.com> <499E7B9B.6030603@trash.net> <49A01932.4090004@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61288 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbZBWJzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 04:55:50 -0500
In-Reply-To: <49A01932.4090004@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> Patrick McHardy wrote:
>> Is sysfs really the best choice for this? It has the usual problems,
>> you can't change multiple parameters at once atomically. Now, I don't
>> know whether this is actually (and currently) a problem for CAN, but
>> given that we already have a generic netlink interface for creating
>> network interfaces that can easily support this, what are the reasons
>> for adding a new interface instead of using the existing one?
> 
> You refer to the API described at http://lwn.net/Articles/236919/, I
> assume.

Exactly.

> Well, I know that netlink is used to define routes in the kernel
> or VLANs but I was not aware that it can also be used to configure real
> network devices. What a pity. At a first glance, I could also be used
> for CAN, of course. There are the following requirements:
> 
> 1. Set and get CAN device properties like bit-rate and controller mode.
> 2. Show CAN bus state (active, error-passive or bus-off).
> 3. Get device constants like clock frequency and bit-timing parameters.
> 4. Dump CAN device statistics.
> 5. Trigger device restart if CAN bus-off state has been detected.
> 
> Not sure yet, if the interface if good for all purposes. Especially
> point 5. might be better handled by an IOCTL.

The first points sound pretty regular. The last one - just triggering
it is no problem of course, but since I don't know how the detection
works, I can't really tell whether its suitable.

> And we need a user space
> tool, e.g. canconfig, to handle the user requests and communicate with
> the kernel side.

Thats pretty standard :)

> We will follow that promising route. Any further help
> or link is appreciated. Thanks.

It should be quite easy to move your interface on top. A few examples
that might be useful are vlan, ip_gre and macvlan.
