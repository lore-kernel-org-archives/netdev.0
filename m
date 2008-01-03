From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2.6.23.12] net/bonding: option to specify initial bond interface number
Date: Thu, 03 Jan 2008 09:03:51 -0800
Message-ID: <29661.1199379831@death>
References: <413FEEF1743111439393FB76D0221E4809790A30@leopard.zoo.q9networks.com>
Cc: netdev@vger.kernel.org
To: "Jari Takkala" <Jari.Takkala@Q9.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:55781 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbYACREH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 12:04:07 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m03H45Lb014197
	for <netdev@vger.kernel.org>; Thu, 3 Jan 2008 12:04:05 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m03H3sak109838
	for <netdev@vger.kernel.org>; Thu, 3 Jan 2008 10:03:58 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m03H3sUv010603
	for <netdev@vger.kernel.org>; Thu, 3 Jan 2008 10:03:54 -0700
In-reply-to: <413FEEF1743111439393FB76D0221E4809790A30@leopard.zoo.q9networks.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jari Takkala <Jari.Takkala@Q9.com> wrote:

>On Wednesday, January 02, 2008 17:24, Jay Vosburgh wrote:
>> 	What advantage does this have over:
>> 
>> # echo +bond5 > /sys/class/net/bonding_masters
>> 
>> 	which will create a new bonding master for the already-loaded driver?
>>
>
>The advantage is that you can load multiple instances of the bonding
>driver and control the name of the bond interface that will be
>created. Normally the bond interface name would take the next available
>number.
>
>In our startup scripts we need to be able to ensure that the interface
>name is consistent across reboots. Sometimes bond1 may be brought up
>before bond0 and it may have different options (requiring a different
>instance of the bonding driver).

	With the sysfs interface to bonding, your last statement is not
true; any number of bonding interfaces, with arbitrary names, can be
created and have their options set without loading multiple instances of
the bonding driver.

>I understand that the startup scripts could be modified to account for
>this, however we also have an IOS like interface to an embedded system
>where the user can create new bond interfaces and specify the interface
>number, they may create interfaces out of order and this feature enables
>them to accomplish that.

	Does your embedded system have sysfs available?  If it does,
then it's to your advantage to use the sysfs API; for one thing, the
single instance of the bonding driver with all interfaces through it
should utilize fewer resources than loading the driver repeatedly.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
