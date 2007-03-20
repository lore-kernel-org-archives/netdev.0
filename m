From: Zacco <zacco@fw.hu>
Subject: Re: many sockets, slow sendto
Date: Tue, 20 Mar 2007 22:59:10 +0100
Message-ID: <4600592E.80605@fw.hu>
References: <E1HObHK-0000WB-00@osiris.swi.hu>	<20070306182039.GJ25760@galon.ev-en.org>	<45FF185B.4070007@fw.hu> <20070319.161611.70218081.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: baruch@ev-en.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta01.mail.t-online.hu ([195.228.240.50]:56267 "EHLO
	mta01.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729AbXCTV6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 17:58:43 -0400
In-Reply-To: <20070319.161611.70218081.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

David Miller wrote:
> From: Zacco <zacco@fw.hu>
> Date: Tue, 20 Mar 2007 00:10:19 +0100
>
>   
>> As you recommended, I used oprofile and it turned out that the 
>> __udp4_lib_lookup function spent most of the time. There is a udp hash 
>> table and the sockets are sought based on the 7 LSBs of the destination 
>> port number. So what happened is now quite obvious: I had many thousands 
>> of sockets, all with the same destination port, thus linked in the same 
>> slot of this hash table. I tried using different ports and it
>> was much faster then.
>>     
>
> There isn't much we can do here.  I bet your destination address
> is unchanging just like your destination ports.
>   
As I'm simulating independent users on one host, each user has a 
different IP address, but each with the same port. So unlike the port, 
the address is changing, basically it's a huge A-class range.

> UDP apps can and do bind to specific destination addresses and
> ports, but the source side is usually wild-carded.
>   
Right, usually it is, but in my case the source addresses are also 
bound, otherwise the source address would be the primary address of the 
physical interface; however, I need to simulate users as if they were on 
separate hosts.
> Are both the source address and port fully specified for your
> sockets?  Maybe we can do something using if that's the case...
>   
You made me curious.  :)  What do you have in mind?

thx: Zacco
