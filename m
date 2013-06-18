From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: UDP "accept" proposed
Date: Tue, 18 Jun 2013 12:41:04 +0200
Message-ID: <51C03940.9020704@redhat.com>
References: <51C01EDA.30705@openvpn.net> <51C02DD9.3050308@redhat.com> <1371550627.3252.243.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Yonan <james@openvpn.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49418 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754050Ab3FRKlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 06:41:09 -0400
In-Reply-To: <1371550627.3252.243.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2013 12:17 PM, Eric Dumazet wrote:
> On Tue, 2013-06-18 at 11:52 +0200, Daniel Borkmann wrote:
>> On 06/18/2013 10:48 AM, James Yonan wrote:
>> [...]
>>> This is a disaster from a performance perspective because you can't take a UDP server that
>>   > binds to a single port and efficiently scale it up across multiple threads or processors
>>   > because you must operate off a single socket.
>
> Well not with current linux ;)
>
>>> But this would be a huge performance win for UDP servers (I'm thinking about OpenVPN in
>>   > particular) because making the kernel smarter about dispatching UDP datagrams would make it
>>   > much easier to develop scalable UDP servers on Linux.
>
>>
>> So SO_REUSEPORT that was added in 3.9 by Tom Herbert wouldn't
>> help in your case (+ f.e. steering flows to CPUs locally) ?
>>
>>     https://lwn.net/Articles/542629/
>
> Yes, but no need for particular steering.
>
> Incoming UDP message will match the 'connected socket' and will be
> delivered to the socket.
>
> RFS will then automatically do the right thing
>   ( Documentation/networking/scaling.txt )

+1, this was what I meant. I should have been more specific. ;-)

> Note that if you have a lot of sockets bound to the same port,
> this fix is needed :
>
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=c87a124a5d5e8cf8e21c4363c3372bcaf53ea190
