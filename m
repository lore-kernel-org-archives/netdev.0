From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: Loopback and net namespace
Date: Sat, 25 Apr 2009 21:50:14 +0200
Message-ID: <49F36976.4090701@free.fr>
References: <alpine.LNX.2.00.0904242322490.1162@duch.mimuw.edu.pl> <20090424.221923.232357312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ebiederm@maxwell.aristanetworks.com
To: emil@linux.org.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:39561 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbZDYTuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 15:50:24 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.1/8.13.1) with ESMTP id n3PJoJSL024571
	for <netdev@vger.kernel.org>; Sat, 25 Apr 2009 19:50:19 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3PJoJDD3321980
	for <netdev@vger.kernel.org>; Sat, 25 Apr 2009 21:50:19 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3PJoIe2002628
	for <netdev@vger.kernel.org>; Sat, 25 Apr 2009 21:50:18 +0200
In-Reply-To: <20090424.221923.232357312.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: emil@linux.org.pl
> Date: Fri, 24 Apr 2009 23:55:36 +0200 (CEST)
>
>   
>> Currently it is impossible to use both net namespace and sysfs
>> because sysfs does not allow two devices with the same name
>> and each net namespace has to have loopback device.
>>
>> To have this working there must be possibility to
>> create loopback devices with different names.
>>
>> The easiest way to acomplish this seems to be with this patch below.
>>
>> I know the devices will be seen in each namespace, but sometimes
>> the only thing that is needed is network environment separation.
>> For example when I need to run two different services on the same TCP
>> port
>> bound to 0.0.0.0.
>>
>> This patch will not break anything and allow people to test
>> net namespace functionality.
>>     
I don't think you have to patch anything if you try a kernel >= 2.6.29.
The sysfs restriction has been solved by disabling the registering of 
the kobject when we are not in the initial network namespace.

For more information you can check this commit:

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6-stable.git;a=commit;h=3891845e1ef6e6807075d4241966b26f6ecb0a5c

Regards,
  -- Daniel
