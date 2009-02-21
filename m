From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 3/8] can: CAN Network device driver and SYSFS interface
Date: Sat, 21 Feb 2009 16:09:38 +0100
Message-ID: <49A01932.4090004@grandegger.com>
References: <1235070082-7069-1-git-send-email-wg@grandegger.com> <1235070082-7069-2-git-send-email-wg@grandegger.com> <1235070082-7069-3-git-send-email-wg@grandegger.com> <1235070082-7069-4-git-send-email-wg@grandegger.com> <499E7B9B.6030603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:57687 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179AbZBUPJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 10:09:43 -0500
In-Reply-To: <499E7B9B.6030603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Wolfgang Grandegger wrote:
>> The CAN network device driver interface provides a generic interface to
>> setup, configure and monitor CAN network devices. It exports a set of
>> common data structures and functions, which all real CAN network device
>> drivers should use. Please have a look to the SJA1000 or MSCAN driver
>> to understand how to use them. The name of the module is can-dev.ko.
>>
>> Furthermore adds a SYSFS interface to set and get CAN device properties.
>> When the CAN device is registered, a set of SYSFS files is created in
>> "/sys/class/net/canX/". These files allow to set and get device
>> properties like bit-timing parameters, state, controller mode and CAN
>> statistics.
> 
> Is sysfs really the best choice for this? It has the usual problems,
> you can't change multiple parameters at once atomically. Now, I don't
> know whether this is actually (and currently) a problem for CAN, but
> given that we already have a generic netlink interface for creating
> network interfaces that can easily support this, what are the reasons
> for adding a new interface instead of using the existing one?

You refer to the API described at http://lwn.net/Articles/236919/, I
assume. Well, I know that netlink is used to define routes in the kernel
or VLANs but I was not aware that it can also be used to configure real
network devices. What a pity. At a first glance, I could also be used
for CAN, of course. There are the following requirements:

1. Set and get CAN device properties like bit-rate and controller mode.
2. Show CAN bus state (active, error-passive or bus-off).
3. Get device constants like clock frequency and bit-timing parameters.
4. Dump CAN device statistics.
5. Trigger device restart if CAN bus-off state has been detected.

Not sure yet, if the interface if good for all purposes. Especially
point 5. might be better handled by an IOCTL. And we need a user space
tool, e.g. canconfig, to handle the user requests and communicate with
the kernel side. We will follow that promising route. Any further help
or link is appreciated. Thanks.

Wolfgang.



