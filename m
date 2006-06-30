From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Thu, 29 Jun 2006 21:18:11 -0400
Message-ID: <1151630291.8922.128.camel@jzny2>
References: <1151626099.8922.64.camel@jzny2>
	 <20060629.171215.112621072.davem@davemloft.net>
	 <1151627180.8922.81.camel@jzny2>
	 <20060629.172948.59656719.davem@davemloft.net>
	 <1151628520.8922.99.camel@jzny2>  <20060630005535.GD14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:34718 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751378AbWF3BSR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 21:18:17 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fw7eI-00006x-QS
	for netdev@vger.kernel.org; Thu, 29 Jun 2006 21:18:22 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630005535.GD14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 02:55 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-29 20:48

> The point is to avoid having an atomic operation for every packet
> when setting iif in netif_receive_skb(). If it was only for
> mirred nobody would complain I guess.
> 

I never intended to punish all users. I think i was misunderstood.
The only problem is where do you decrement the refcount when you
increment at mirred?
In your case, I assume it is at some sort of rule destruction?

> > I think whether it becomes ifindex or pointer you need to increment the
> > refcounter. and decrement somewhere.
> > The challenge for me is a choice to use more cycles if you use ifindex
> > vs less cycles with a pointer. The advantage for going with ifindex
> > would be to save those bits(if you rearrange). The question is which is
> > reasonable?;->
> 
> The third choice is to just don't care if the interface goes away
> but have a chance to figure it out and just assume as if it would
> have never been set. The number of devices that can disappear w/o
> user control is very very limited and not worth an atomic operation
> for every single packet.
> 

Now that you mention this - I think that option 3 is what we said last
time we had this discussion ;->

cheers,
jamal

