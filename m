From: Jason Wessel <jason.wessel@windriver.com>
Subject: Re: NETPOLL=y , NETDEVICES=n compile error ( Re: 2.6.23-rc1-mm1 )
Date: Tue, 31 Jul 2007 06:44:52 -0500
Message-ID: <46AF20B4.4050203@windriver.com>
References: <20070731083210.GA1797@ff.dom.local> <46AF0B8C.7070006@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	amitkale@linsyssoft.com
To: Gabriel C <nix.or.die@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37249 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750847AbXGaLpk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 07:45:40 -0400
In-Reply-To: <46AF0B8C.7070006@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gabriel C wrote:
> Jarek Poplawski wrote:
>   
>> On 28-07-2007 20:42, Gabriel C wrote:
>>     
>>> Andrew Morton wrote:
>>>       
>>>> On Sat, 28 Jul 2007 17:44:45 +0200 Gabriel C <nix.or.die@googlemail.com> wrote:
>>>>
>>>>         
>>>>> Hi,
>>>>>
>>>>> I got this compile error with a randconfig ( http://194.231.229.228/MM/randconfig-auto-82.broken.netpoll.c ).
>>>>>
>>>>> ...
>>>>>
>>>>> net/core/netpoll.c: In function 'netpoll_poll':
>>>>> net/core/netpoll.c:155: error: 'struct net_device' has no member named 'poll_controller'
>>>>> net/core/netpoll.c:159: error: 'struct net_device' has no member named 'poll_controller'
>>>>> net/core/netpoll.c: In function 'netpoll_setup':
>>>>> net/core/netpoll.c:670: error: 'struct net_device' has no member named 'poll_controller'
>>>>> make[2]: *** [net/core/netpoll.o] Error 1
>>>>> make[1]: *** [net/core] Error 2
>>>>> make: *** [net] Error 2
>>>>> make: *** Waiting for unfinished jobs....
>>>>>
>>>>> ...
>>>>>
>>>>>
>>>>> I think is because KGDBOE selects just NETPOLL.
>>>>>
>>>>>           
>>>> Looks like it.
>>>>
>>>> Select went and selected NETPOLL and NETPOLL_TRAP but things like
>>>> CONFIG_NETDEVICES and CONFIG_NET_POLL_CONTROLLER remain unset.  `select'
>>>> remains evil.
>>>>         
>> ...
>>     
>>> I think there may be a logical issue ( again if I got it right ).
>>> We need some ethernet card to work with kgdboe right ? but we don't have any if !NETDEVICES && !NET_ETHERNET.
>>>
>>> So maybe some ' depends on ... && NETDEVICES!=n && NET_ETHERNET!=n ' is needed too ? 
>>>       
>> IMHO, the only logical issue here is netpoll.c mustn't use 
>> CONFIG_NET_POLL_CONTROLLER code without #ifdef if it doesn't
>> add this dependency itself.
>>
>>     
>
> Well it does if NETDEVICES && if NET_ETHERNET which booth are N when !NETDEVICES is why KGDBOE uses select and not depends on.
>
> Now KGDBOE just selects NETPOLL and NETPOLL_TRAP.
> Adding 'select CONFIG_NET_POLL_CONTROLLER' let kgdboe compiles but the question is does it work without any ethernet card ?
>   

kgdboe is completely useless without a network card that has a polling 
driver.  It seems to me that the simple and easy fix is to set it to 
depend on NETDEVICES but allow it to use select on NETPOLL.

Would that seem reasonable?

Jason.
