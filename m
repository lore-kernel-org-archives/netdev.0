From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Thu, 29 Jun 2006 20:48:40 -0400
Message-ID: <1151628520.8922.99.camel@jzny2>
References: <1151626099.8922.64.camel@jzny2>
	 <20060629.171215.112621072.davem@davemloft.net>
	 <1151627180.8922.81.camel@jzny2>
	 <20060629.172948.59656719.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:62155 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S964832AbWF3Asn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 20:48:43 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fw7Bg-00041w-Qt
	for netdev@vger.kernel.org; Thu, 29 Jun 2006 20:48:48 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060629.172948.59656719.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-29-06 at 17:29 -0700, David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Thu, 29 Jun 2006 20:26:20 -0400
[..]
> > I see; i take it if things were moved around that may change?
> 
> Yes.
> 

Ok, relief - so i was not totally unreasonable then ;->

> > Can you avoid doing the refcount?
> > Note Thomas is doing dev_get_by_index (which will do the atomic ref
> > count).
> 
> He is doing that where skb->input_device is needed, which is
> what we want.
> 

I am saying the same thing as well - i think. mirred touches
the input_dev and therefore setting the refcount in mirred is valid -
but iam unsure where to unset it.

> > I didnt quiet follow, the ref count seems only needed in the
> > redirection, no?
> 
> I'm saying that, we don't need the refcount, just setting
> the skb->input_index thing, unless someone actually cares
> about the input device.
> 

the ifb references it; only mirred redirects to the ifb at the moment.
You would need to increment in mirred, no?
Why do i feel i am missing something? ;->

> As long as the packet hits not paths that care about the
> SKB input device, no atomic refcounts are taken.  It's
> just an integer sitting there in the SKB.

indeed. 
I think whether it becomes ifindex or pointer you need to increment the
refcounter. and decrement somewhere.
The challenge for me is a choice to use more cycles if you use ifindex
vs less cycles with a pointer. The advantage for going with ifindex
would be to save those bits(if you rearrange). The question is which is
reasonable?;->

cheers,
jamal 

