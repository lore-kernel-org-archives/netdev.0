From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: [PATCH v3] net-tcp: TCP/IP stack bypass for loopback connections
Date: Thu, 20 Sep 2012 07:28:41 -0400
Message-ID: <505AFDE9.4080602@earthlink.net>
References: <1347908305-13541-1-git-send-email-brutus@google.com>	<1347913239.26523.173.camel@edumazet-glaptop>	<20120919.163406.487082174277409074.davem@davemloft.net>	<1348088634.31352.26.camel@edumazet-glaptop> <CAEkNxbEJjAu3+3yDGPGSzzee-LY_797RdNbBgcC6=-aDHfEAJQ@mail.gmail.com>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org
To: Bruce Curtis <brutus@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:59127 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753951Ab2ITL2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 07:28:46 -0400
In-Reply-To: <CAEkNxbEJjAu3+3yDGPGSzzee-LY_797RdNbBgcC6=-aDHfEAJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2012 05:19 PM, Bruce Curtis wrote:
> On Wed, Sep 19, 2012 at 2:03 PM, Eric Dumazet<eric.dumazet@gmail.com>  wrote:
>    
>> On Wed, 2012-09-19 at 16:34 -0400, David Miller wrote:
>>
>>      
>>> I have an idea on how to handle this.
>>>
>>> In drivers/net/loopback.c:loopback_tx(), skip the SKB orphan operation
>>> if there is a friend socket at skb->friend.
>>>
>>> When sending such friend SKBs out at connection startup, arrange it
>>> such that the skb->destructor will zap the skb->friend pointer to
>>> NULL.
>>>
>>> Also, in skb_orphan*(), if necessary, set skb->friend to NULL.
>>>
>>> skb->sk will hold a reference to the socket, and since skb->friend
>>> will be equal, this will make sure a pointer to an unreferenced
>>> socket does not escape.
>>>        
>> I now am wondering if we still need skb->friend field.
>>
>> If skb->sk is not zeroed by a premature skb_orphan(), then
>>
>> skb->sk->sk_friend gives the friend ?
>>
>>
>>      
Does this mean traffic on the loopback interface will not traverse 
netfilter?

-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)
