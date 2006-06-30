From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Thu, 29 Jun 2006 20:26:20 -0400
Message-ID: <1151627180.8922.81.camel@jzny2>
References: <20060629233933.GB14627@postel.suug.ch>
	 <20060629.164732.41636454.davem@davemloft.net>
	 <1151626099.8922.64.camel@jzny2>
	 <20060629.171215.112621072.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:37348 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S964809AbWF3A0X
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 20:26:23 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fw6q4-0003vx-P0
	for netdev@vger.kernel.org; Thu, 29 Jun 2006 20:26:28 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060629.171215.112621072.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-29-06 at 17:12 -0700, David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Thu, 29 Jun 2006 20:08:19 -0400
> 
> > What am i missing?
> > on 64bit machine, does it not save 32 bits to use an ifindex as opposed
> > to the pointer?
> 
> The objects around it are pointers, which are 64-bit, and thus
> the 32-bit object gets padded out to 64-bits in the layout of
> the struct so that the next pointer member can be properly
> aligned.
> 
> It does not change the size of sk_buff at all.
> 

I see; i take it if things were moved around that may change?

> > Yes, it is a bug, but:
> > dev_hold/put dont work anymore? why do you need an ifindex instead?
> 
> You sure you want to do that atomic operation on every single
> input packet, regardless of whether egress operations are
> using it or not?
> 

Can you avoid doing the refcount?
Note Thomas is doing dev_get_by_index (which will do the atomic ref
count).

For me the choice is between having the iif and:
- __get device from ifindex
- reference dev->something

vs getting the input_dev and
- reference dev->something

> We should put the cost of features at the actual users, and not
> impose it upon everyone.

I didnt quiet follow, the ref count seems only needed in the
redirection, no?

cheers,
jamal

