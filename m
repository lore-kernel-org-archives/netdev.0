From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: Bug in 2.6.10
Date: Fri, 28 Jan 2005 21:03:39 +0100
Message-ID: <41FA9A9B.2000601@rapidforum.com>
References: <41FA9239.4010401@rapidforum.com>	<20050128114251.64e0fff4@dxpl.pdx.osdl.net> <20050128114600.46f3a70a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050128114600.46f3a70a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>Hello.
>>>
>>>In 2.6.10 there has been a "bug" introduced. You may also call it a feature, but its a crappy 
>>>feature for big servers. It seems the kernel is dynamically adjusting the buffer-space available for 
>>>sockets. Even if send-buffer has been set to 1024 KB, the kernel blocks at less if there are enough 
>>>sockets in use. If you have 10 sockets with 1024 KB each, they do not block at all, using full 1024 
>>>KB. If you have 4000 sockets, they only use 200 KB. So it seems its blocking at 800 MB. This is 
>>>good, if you have a 1/3 system, because else the kernel would run out of low mem. But I have a 2/2 
>>>system and I need them for buffers. So what can I do? Where can I adjust the "pool"?
>>
>>You can set the upper bound by setting tcp_wmem. There are three values
>>all documented in Documentation/networking/ip-sysctl.txt
> 
> 
> This feature is meant also to prevent remote denial of service
> attacks.  It limits the amount of system memory TCP can
> consume on your system.
> 
> Before this feature went in, it's really easy to remotely make a system
> consume %90 of system memory just with socket buffers.

Thank you for your reply.

Yes this is possible for most situations. Isn't there a way to disable it or at least adjust the 
level? As said, I have a 2/2 system and I would like to set it to 1500 MB. this is important for my 
big server.

Oh and for that DOS-thingy, my two cents: It would be better if buffer-sockets are dynamically 
adjusted. So that memory is only allocated if the queue is really needed. Most of the allocated 
memory is mostly unused because queues are mostly empty.

Please help me.

Thank you in advance,
Chris
