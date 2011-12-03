From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: SYN attack, with FIN flag set
Date: Sat, 03 Dec 2011 11:07:10 +0200
Message-ID: <73da1a18b48dc3097acd6728be208c66@visp.net.lb>
References: <1755dc626dee301261ef4fe4cd66fd47@visp.net.lb>
 <1322897233.2762.79.camel@edumazet-laptop>
 <1322898902.2762.81.camel@edumazet-laptop>
 <b3ae04aef6b0ce233e8e8978782d1ccc@visp.net.lb>
 <1322902401.2762.85.camel@edumazet-laptop> <4ED9E5FA.30204@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:44426 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417Ab1LCJHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 04:07:11 -0500
In-Reply-To: <4ED9E5FA.30204@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Sat, 03 Dec 2011 13:03:54 +0400, Michael Tokarev wrote:
> On 03.12.2011 12:53, Eric Dumazet wrote:
> []
>> TCP stack first tries to lookup a socket, given the tuple found in
>> incoming packet.
>>
>> This is where your machine is hit : we find the listener socket and 
>> lock
>> it.
>>
>> Then, once socket was found and locked, state machine handle various
>> possible states.
>>
>> In your case, you want to bypass the lookup, and eventually bypass 
>> the
>> IP route lookup as well (to keep IP route cache small)
>>
>> iptables -t raw -I PREROUTING -p tcp --tcp-flags SYN,FIN SYN,FIN -j 
>> DROP
>
> Maybe it makes some sence to add a basic "sanity" check rule
> before the socket lookup?
>
> The question here is why SYN+FIN results in worse behavour than
> SYN alone - in the default setup, without iptables rules?  As
> far as I understand, "regular" SYN attack is handled just fine,
> but SYN+FIN attack makes the machine to "choke", and it is not
> obvious how to fix it -- naive --syn iptables rule does not help.
>
> The price for the sanity check appears to be small since there's
> already a check for RST.
>
> Just asking, not suggesting anything... ;)
>
> Thanks,
>
> /mjt
 No,no, as i understand it is just threating SYN+FIN as plain SYN.
 I think if it incurr additional expenses (verification), no need maybe 
 to fix it, it is job of iptables.
 But is FIN to listening socket - legitimate? Shouldn't it be dropped?

 ---
 System administrator
 Denys Fedoryshchenko
 Virtual ISP S.A.L.
