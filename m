From: Patrick McHardy <kaber@trash.net>
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Wed, 16 Jan 2008 06:02:00 +0100
Message-ID: <478D8FC8.9000107@trash.net>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net> <478D226E.1050209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59771 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbYAPFCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 00:02:19 -0500
In-Reply-To: <478D226E.1050209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Patrick McHardy wrote, On 01/15/2008 05:05 PM:
> 
>> Badalian Vyacheslav wrote:
> 
> ...
> 
>> Yes, packets in the old qdisc are lost.
>>
>>> Maybe if tc do changes - need create second queue (hash of rules or how 
>>> you named it?) and do changes at it. Then replace old queue rules by 
>>> created new.
>>> Logic -
>>> 1. Do snapshot
>>> 2. Do changes in shapshot
>>> 3. All new packets go to snapshot
>>> 4. If old queue not have packets - delete it.
>>> 5. Snapshot its default.
>>
>> That doesn't really work since qdiscs keep internal state that
>> in large parts depends on the packets queued. Take the qlen as
>> a simple example, the new qdisc doesn't know about the packets
>> in the old one and will exceed the limit.
> 
> But, some similar alternative to killing packets 'to death' could
> be imagined, I suppose (in the future, of course!). So, e.g. doing
> the switch automatically after last packet has been dequeued (maybe
> even with some 'special' function/mode for this). After all even
> with accuracy lost, it could be less visible for clients than
> current way?


This would need support from the qdiscs to do it properly. Looks
non-trivial for HTB/HFSC/CBQ, but the others shouldn't be that hard.

