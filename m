From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: more troubles with bridge in netns
Date: Mon, 14 Sep 2009 13:28:59 +0200
Message-ID: <4AAE28FB.4060201@free.fr>
References: <200909071807.54511.atis@mikrotik.com> <4AA6188C.1070806@free.fr> <200909141419.12330.atis@mikrotik.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Atis Elsts <atis@mikrotik.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:59269 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbZINL3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 07:29:01 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.1/8.13.1) with ESMTP id n8EBT4G3019141
	for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 11:29:04 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8EBT4GE1167564
	for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 12:29:04 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8EBT3Br005028
	for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 12:29:03 +0100
In-Reply-To: <200909141419.12330.atis@mikrotik.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Atis Elsts wrote:
> On Tuesday 08 September 2009 11:40:44 Daniel Lezcano wrote:
>   
>> Atis Elsts wrote:
>>     
>>> Trying to add bridge interface from userspace program, after moving the
>>> program to a new network namespace, causes kernel to crash. I am using
>>> latest kernel version from git (2.6.31-rc9).
>>> The bug is easy to reproduce - just compile and run the attached C
>>> program.
>>>
>>> I see that bridge interface has NETIF_F_NETNS_LOCAL flag, but as I
>>> understand, this flag simply means that a device cannot be *moved* across
>>> network namespaces, not that it cannot be *created* in other namespaces.
>>>       
>> Yep, very easy to reproduce :/
>> The sysfs has not been disabled for the bridge. I will try to fix it as
>> soon as I can.
>>
>> Thanks
>>   -- Daniel
>>     
>
> Hello,
>
> please let me know when the sysfs patch for bridge is available. At the moment 
> I managed to get it to work by just commenting out all sysfs stuff for bridge 
> module. However, a new problem appears now. After running C program 
> (attached) that creates a bridge in network namespace and attaches an 
> interface to it, I got this message repeatedly:
>  kernel:[  466.758908] unregister_netdevice: waiting for lo to become free. 
> Usage count = 2
>
> It sems pretty unlikely that my kernel changes could have caused this?
>
> The unregister_netdevice message does not appear, however, if I uncomment this 
> line in child.c:
>     system("brctl setfd sim_br0 0");
>   

I was about to send a patch to disable the bridge per namespace as it 
seems it was never tested.
Can you send me your kernel patch ?

Thanks.
  -- Daniel
