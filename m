From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 8/9]: sch_hfsc: Use ->requeue queue instead of ops.
Date: Thu, 21 Aug 2008 00:09:32 +0200
Message-ID: <20080820220931.GA3071@ami.dom.local>
References: <20080818.013715.51438108.davem@davemloft.net> <48A9832D.7030402@trash.net> <20080818.222917.10471071.davem@davemloft.net> <48AAC57E.1090504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:33641 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbYHTWHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 18:07:55 -0400
Received: by nf-out-0910.google.com with SMTP id d3so323429nfc.21
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 15:07:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48AAC57E.1090504@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 03:07:10PM +0200, Patrick McHardy wrote:
> David Miller wrote:
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Mon, 18 Aug 2008 16:11:57 +0200
>>
>>> I think we really need either ->requeue or a real ->peek operation.
>>
>> All the code duplication and complexity is what I'm trying to avoid.
>>
>> I see no value in overhauling and auditing all of these ->requeue()
>> implementations and how they return status codes when the facility
>> itself is largely superfluous.
>>
>> Maybe we can simply add a "bool peek" argument or some flags to
>> ->dequeue() instead.
>
> Yes, that should work. It might get a big ugly though since the
> ->dequeue functions have to make sure not to modify any state
> while peeking.

I'm not sure what are conclusions here wrt. this patchset, but since
David made this mistake and added me to CC, here are my doubts:

- maybe I miss something, but it seems there is something strange with
  using qdisc_dequeue(), e.g. how htb_dequeue_queue() in this call
  skb = qdisc_dequeue(cl->un.leaf.q);
  can ever get anything here?:
  struct sk_buff *skb = __skb_dequeue(&sch->requeue);
  Isn't it requeued in root qdisc? But even if it's OK, isn't there
  needed some additional code to control queue length?

- initially David wrote about simplifying this, so I thought it's
  about some simple buffer outside of qdiscs' code; now it's a bit
  more than this; sure, it's simpler but I guess, soon, after a few
  (ADSL?) fixes and optimizations there will be probably no difference.
  Peeking doesn't look to me necessarily simpler either.

So, IMHO, if it's not going to be something really simple I doubt it's
worth to bother with this. Anyway, I hope David will give some warning
yet before merging this.

Thanks,
Jarek P.
