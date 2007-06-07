From: Pavel Emelianov <xemul@openvz.org>
Subject: Re: [PATCH] Virtual ethernet tunnel
Date: Thu, 07 Jun 2007 13:51:52 +0400
Message-ID: <4667D538.7040904@openvz.org>
References: <4666CEAA.8010903@openvz.org> <4666D296.2000002@trash.net> <4667BD1D.9080905@openvz.org> <4667D00E.2020605@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Kirill Korotaev <dev@openvz.org>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:22480 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446AbXFGJrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 05:47:19 -0400
In-Reply-To: <4667D00E.2020605@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> I did this at the very first version, but Alexey showed me that this
>> would be wrong. Look. When we create the second device it must be in
>> the other namespace as it is useless to have them in one namespace.
>> But if we have the device in the other namespace the RTNL_NEWLINK
>> message from kernel would come into this namespace thus confusing ip
>> utility in the init namespace. Creating the device in the init ns and
>> moving it into the new one is rather a complex task.
>>   
> Pavel,
> 
> moving the netdevice to another namespace is not a complex task. Eric
> Biederman did it in its patchset ( cf.  http://lxc.sf.net/network )

By saying complex I didn't mean that this is difficult to implement,
but that it consists (must consist) of many stages. I.e. composite.
Making the device right in the namespace is liter.

> When the pair device is created, both extremeties are into the init
> namespace and you can choose to which namespace to move one extremity.

I do not mind that.

> When the network namespace dies, the netdev is moved back to the init
> namespace.
> That facilitate network device management.
> 
> Concerning netlink events, this is automatically generated when the
> network device is moved through namespaces.
> 
> IMHO, we should have the network device movement between namespaces in
> order to be able to move a physical network device too (eg. you have 4
> NIC and you want to create 3 containers and assign 3 NIC to each of them)

Agree. Moving the devices is a must-have functionality.

I do not mind making the pair in the init namespace and move the second
one into the desired namespace. But if we *always* will have two ends in
different namespaces what to complicate things for?

Thanks,
Pavel
