From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [RFC, PATCH] netlink based mq_notify(SIGEV_THREAD)
Date: Sun, 04 Apr 2004 09:11:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406FB51E.3090001@colorfullife.com>
References: <406F13A1.4030201@colorfullife.com>	 <1081023487.2037.19.camel@jzny.localdomain>	 <406F21FB.4010502@colorfullife.com> <1081029667.2037.55.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        Michal Wronski <wrona@mat.uni.torun.pl>,
        Krzysztof Benedyczak <golbi@mat.uni.torun.pl>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1081029667.2037.55.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>Your split of netlink_unicast seems fine ; 
>I guess the bigger question is whether this interface could be a
>speacilized netlink protocol instead? It doesnt seem too nasty as is
>right now, just tending towards cleanliness.
>It seems that user space must first open a netlink socket for this to
>work but somehow the result skb is passed back to userspace using the
>mq_notify and not via the socket interface opened?
>
No, the result is returned via the socket fd. It's just created due to 
the mq_notify call.

> Why should user space
>even bother doing this? The kernel could on its behalf, no? Are you sure
>there will always be one and only one message outstanding always?
>  
>
There can be multiple messages outstanding. Each sucessful mq_notify 
call generates exactly one message, but a process could create multiple 
message queues and then there can be multiple messages in the 
notification socket.

--
    Manfred
