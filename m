From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next 3/9] mlx4: Implement port type setting via
 devlink interface
Date: Tue, 23 Feb 2016 14:28:05 +0100
Message-ID: <56CC5E65.40809@stressinduktion.org>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <1456165924-14399-4-git-send-email-jiri@resnulli.us>
 <56CC41C8.10802@stressinduktion.org> <20160223122109.GD2140@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:33841 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751880AbcBWN2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 08:28:12 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id C69E320A7D
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 08:28:11 -0500 (EST)
In-Reply-To: <20160223122109.GD2140@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.02.2016 13:21, Jiri Pirko wrote:
> Tue, Feb 23, 2016 at 12:26:00PM CET, hannes@stressinduktion.org wrote:
>> Hi Jiri,
>>
>> On 22.02.2016 19:31, Jiri Pirko wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> So far, there has been an mlx4-specific sysfs file allowing user to
>>> change port type to either Ethernet of InfiniBand. This is very
>>> inconvenient.
>>
>> Again, I want to express my concerns regarding all of this until this will be
>> integrated into udev/systemd for stable device names. While one can build
>> wrapper code around devlink to have stable devlink ports, I don't see a
>> reason to include kernel code which actually has more problems than the sysfs
>> approach. This harms admins to use those devices and will additionally
>> require user space to write boiler plate code.
>
> Sysfs is not the place to do this things. It was already discussed here
> multiple times. There was and attempt to use configfs, which was also
> refused. Netlink is the only place to go. For multiple reasons,
> including well defined api and behaviour, notifications, etc.

I am not against netlink at all. My fear with this interface is simply:

1) we introduce another ifindex/name like identifiers. It took a long 
time until this stuff finally worked fine with linux. It needs 
persistent storage in userspace being applied at boot time. Why this 
complications for this probably lesser often used interface?

2) The actual devlink attributes get managed from inside devlink and not 
the driver. So driver need to modify devlink.c/devlink.h in core to add 
new attributes.

1) is easily solvable, just drop the ifindex style attributes and always 
force the user to enter the bus and bus-topology id.

For 2) I don't really know what drivers want, not sure if it is easier 
to add some small helper functions to add sysfs attributes to kobjects 
without necessarily holding a net_device. Thus mellanox drivers can use 
it and I am not sure how many other networking cards allow switching 
ports between ib and eth type. Port splitting only happens for 
interfaces which already have a net_device, no?

> I think it is quite trivial to teach udev to name devlinkX devices
> according to pci address (or any other address). That's all what is
> needed here. I don't understand your concerns.

I don't think that this interface needs the same complexity as network 
interfaces.

I am not sure, but one of the initial problems was that this information 
should already be there before the driver actually gets loaded, no? 
These changes don't solve this problem either?

Thanks,
Hannes
