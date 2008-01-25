From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 3/7 net-2.6.25] [IPV4]: Prohibit assignment of 0.0.0.0
 as interface address.
Date: Fri, 25 Jan 2008 16:12:44 +0100
Message-ID: <4799FC6C.5040705@fr.ibm.com>
References: <1201269123-20378-1-git-send-email-den@openvz.org> <1201269123-20378-3-git-send-email-den@openvz.org> <4799EBBE.6080706@fr.ibm.com> <4799EE8C.60407@sw.ru> <4799F6A5.7040703@fr.ibm.com> <4799FC69.9030809@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, "Denis V. Lunev" <den@openvz.org>,
	netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:51281 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbYAYPQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 10:16:05 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0PFG4kM054748
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 15:16:04 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0PFG4tf4559000
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 15:16:04 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0PFG0RF018840
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 15:16:00 GMT
In-Reply-To: <4799FC69.9030809@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> Daniel Lezcano wrote:
>> Denis V. Lunev wrote:
>>> Daniel Lezcano wrote:
>>>> Denis V. Lunev wrote:
>>>>> I could hardly imagine why sombady needs to assign 0.0.0.0 as an
>>>>> interface
>>>>> address or interface destination address. The kernel will behave in a
>>>>> strage
>>>>> way in several places if this is possible, as ifa_local != 0 is
>>>>> considered
>>>>> as initialized/non-initialized state of the ifa.
>>>> AFAICS, we should be able to set at an interface address to 0.0.0.0, in
>>>> order to remove an IP address from an interface and keep this one up.
>>>> I see two trivial cases:
>>>>  * remove the ipv4 on an interface but continue to use it through ipv6
>>>>  * move ipv4 address from the interface to an attached bridge
>>> For this case there is an IOCTL/netlink "remove IP address".
>> And I forgot to mention the general broadcast.
>> This is need for the dhcp protocol. If you are not able to set your
>> interface to 0.0.0.0, you will be not able to send a 255.255.255.255
>> broadcast message to have your IP address.
>>
> 
> OK. Dave, pls disregard this patch. I suspect that others in the set
> should not intersect with this one.
> 
> To summarize the discussion:
> there is the only reason for this assignment: old IOCTL interface does
> not have a way to remove IP address except this, though netlink has a
> method for it that's why I am a little bit confused :)
> 
> This is handled in the __inet_insert_ifa: ifa is just removed there and,
> correctly, ifa with 0.0.0.0 address can't exists in the kernel.

Yes, my last statement is false.
