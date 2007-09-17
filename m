From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [net-2.6.24][patch 2/2] Dynamically allocate the loopback device
Date: Mon, 17 Sep 2007 20:52:05 +0200
Message-ID: <46EECCD5.5090601@fr.ibm.com>
References: <20070917134509.222896190@mai.toulouse-stg.fr.ibm.com>	<20070917135133.466924283@mai.toulouse-stg.fr.ibm.com> <20070917101314.5d1673da@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	containers@lists.osdl.org, davem@davemloft.net,
	Benjamin Thery <benjamin.thery@bull.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:53772 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652AbXIQSzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 14:55:31 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l8HItUQb036188
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 18:55:30 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8HItTup2465906
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 19:55:29 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8HItMB3027133
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 19:55:23 +0100
In-Reply-To: <20070917101314.5d1673da@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Mon, 17 Sep 2007 15:45:11 +0200
> dlezcano@fr.ibm.com wrote:
> 
>> From: Daniel Lezcano <dlezcano@fr.ibm.com>
>>
>> Doing this makes loopback.c a better example of how to do a
>> simple network device, and it removes the special case
>> single static allocation of a struct net_device, hopefully
>> making maintenance easier.
>>
> 
> What is before/after code and data size, does it make code smaller?

Interesting question, here are the results based on the same config file.

Without the patchset:
----------------------

vmlinux:
    text    data     bss     dec     hex filename
2446606  188243  163840 2798689  2ab461 vmlinux

loopback.o
    text    data     bss     dec     hex filename
     417    1040       8    1465     5b9 drivers/net/loopback.o


With the patchset:
------------------

vmlinux:
    text    data     bss     dec     hex filename
2446853  187187  163840 2797880  2ab138 ./vmlinux

loopback.o
    text    data     bss     dec     hex filename
     609       4      12     625     271 drivers/net/loopback.o


