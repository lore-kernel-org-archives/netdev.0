From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: multicast: bug or "feature"
Date: Wed, 17 Oct 2007 16:19:25 -0400
Message-ID: <47166E4D.70802@hp.com>
References: <4716694D.6030508@hp.com> <47166BD5.7090207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:43491 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863AbXJQUTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 16:19:37 -0400
Received: from smtp2.fc.hp.com (smtp2.fc.hp.com [15.11.136.114])
	by atlrel6.hp.com (Postfix) with ESMTP id 0E38736ECB
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 16:19:27 -0400 (EDT)
In-Reply-To: <47166BD5.7090207@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> Vlad Yasevich wrote:
>> We've been trying to field some questions regarding multicast
>> behavior and one such behavior has stumped us.
>>
>> I've reproduced the following behavior on 2.6.23.
>>
>> The application opens 2 sockets.  One socket is the receiver
>> and it simply binds to 0.0.0.0:2000 and joins a multicast group
>> on interface eth0 (for the test we used 224.0.1.3).  The other
>> socket is the sender.  It turns off MULTICAST_LOOP, sets MULTICAST_IF
>> to eth1, and sends a packet to the group that the first socket
>> joined.
>>
>> We are expecting to receive the data on the receiver socket, but
>> nothing comes back.
>>
>> Running tcpdump on both interfaces during the test, I see the packet
>> on both interfaces, ie. I see it sent on eth0 and received on eth1 with
>> IP statistics going up appropriately.
> 
> I think you got things switched - in the beginning you said that the
> receiver has joined a multicast group on eth0 and the sender set
> MULTICAST_IF to eth1, but in the paragraph just above you say
> transmission is on eth0 and reception is on eth1...

Yes, that was just the typing switch.  The send packet was on eth1
(the checksum wasn't finished yet), and the received packet was
on eth0.

> 
> I am _guessing_ that the MULITCAST_LOOP stuff is implemented with "is
> this datagram's source IP one of the local IP's on the system" rather
> than "is this datagram from my own socket"
> 

Well, from what I've see, MULTICAST_LOOP is checked only on output, so
that doesn't seem to be the issue.

Also, IPv6 works as expected, i.e. I can receive the data in the app
above if I use IPv6 multicast addresses.

-vlad
