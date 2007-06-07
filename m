From: Daniel Lezcano <dlezcano@meiosys.com>
Subject: Re: [PATCH] Virtual ethernet tunnel
Date: Thu, 07 Jun 2007 17:44:37 +0200
Message-ID: <466827E5.9040202@meiosys.com>
References: <4666CEAA.8010903@openvz.org> <4666D296.2000002@trash.net> <4667BD1D.9080905@openvz.org> <4667D00E.2020605@fr.ibm.com> <4667D538.7040904@openvz.org> <466810BF.2090704@fr.ibm.com> <46682387.30007@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Kirill Korotaev <dev@openvz.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:13927 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763929AbXFGPpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 11:45:31 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l57FjSxb168220
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:45:28 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57FjSgo2736134
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 16:45:28 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57FjR6S007941
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 16:45:28 +0100
In-Reply-To: <46682387.30007@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> Daniel Lezcano wrote:
>> Pavel Emelianov wrote:
>>>>> I did this at the very first version, but Alexey showed me that this
>>>>> would be wrong. Look. When we create the second device it must be in
>>>>> the other namespace as it is useless to have them in one namespace.
>>>>> But if we have the device in the other namespace the RTNL_NEWLINK
>>>>> message from kernel would come into this namespace thus confusing ip
>>>>> utility in the init namespace. Creating the device in the init ns and
>>>>> moving it into the new one is rather a complex task.
>>>>>         
>>>> Pavel,
>>>>
>>>> moving the netdevice to another namespace is not a complex task. Eric
>>>> Biederman did it in its patchset ( cf.  http://lxc.sf.net/network )
>>>>     
>>> By saying complex I didn't mean that this is difficult to implement,
>>> but that it consists (must consist) of many stages. I.e. composite.
>>> Making the device right in the namespace is liter.
>>>
>>>  
>>>> When the pair device is created, both extremeties are into the init
>>>> namespace and you can choose to which namespace to move one extremity.
>>>>     
>>> I do not mind that.
>>>  
>>>> When the network namespace dies, the netdev is moved back to the init
>>>> namespace.
>>>> That facilitate network device management.
>>>>
>>>> Concerning netlink events, this is automatically generated when the
>>>> network device is moved through namespaces.
>>>>
>>>> IMHO, we should have the network device movement between namespaces in
>>>> order to be able to move a physical network device too (eg. you have 4
>>>> NIC and you want to create 3 containers and assign 3 NIC to each of
>>>> them)
>>>>     
>>> Agree. Moving the devices is a must-have functionality.
>>>
>>> I do not mind making the pair in the init namespace and move the second
>>> one into the desired namespace. But if we *always* will have two ends in
>>> different namespaces what to complicate things for?
>>>   
>> Just to provide a netdev sufficiently generic to be used by people who
>> don't want namespaces but just want to do some network testing, like Ben
>> Greear does. He mentioned in a previous email, he will be happy to stop
>> redirecting people to out of tree patch.
> 
> This patch creates booth devices in the init namespace. That's what
> you want, isn't it? When we have the namespaces we will be able to
> create the pair with booth ends in the init namespace - just do not
> specify the namespace id to create the 2nd end in and the driver will
> leave it int the init one.

Ok, fine.

