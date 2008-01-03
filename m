From: "Jari Takkala" <Jari.Takkala@Q9.com>
Subject: RE: [PATCH 2.6.23.12] net/bonding: option to specify initial bond interface number
Date: Thu, 3 Jan 2008 14:19:42 -0500
Message-ID: <413FEEF1743111439393FB76D0221E4809790B39@leopard.zoo.q9networks.com>
References: <29661.1199379831@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.q9.com ([216.220.35.252]:34667 "EHLO mx3.q9.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752910AbYACTTo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 14:19:44 -0500
Content-class: urn:content-classes:message
In-Reply-To: <29661.1199379831@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, January 03, 2008 12:04, Jay Vosburgh wrote:
>> In our startup scripts we need to be able to ensure that the
>> interface name is consistent across reboots. Sometimes bond1 may be
>> brought up before bond0 and it may have different options (requiring
>> a different instance of the bonding driver).
> 
> 	With the sysfs interface to bonding, your last statement is not
> true; any number of bonding interfaces, with arbitrary names, can be
> created and have their options set without loading multiple instances
> of the bonding driver.
> 
> 	Does your embedded system have sysfs available?  If it does,
> then it's to your advantage to use the sysfs API; for one thing, the
> single instance of the bonding driver with all interfaces through it
> should utilize fewer resources than loading the driver repeatedly.
> 

We do have sysfs available. I actually did not realize that it is possible to have one bonding instance and create multiple interfaces with different options. It looks like when I initially wrote this patch  (~2.6.20) either this feature was not available, or the bonding documentation may have been out of date. I see now in the latest Documentation/networking/bonding.txt that this is explained clearly.

Thank you for your help, I will drop the patch and move to using the sysfs method. Although I may need to patch it for our own uses to either not create bond0 on module load, or I may just run 'echo -bond0 > /sys/class/net/bonding_masters' immediately after loading the module.

Jari

