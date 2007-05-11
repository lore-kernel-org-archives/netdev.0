From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 07:27:07 -0400
Message-ID: <1178882827.4093.22.camel@localhost>
References: <OF5A173A00.C4FD79C5-ON652572D8.001C203E-652572D8.001D8134@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@US.IBM.COM>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:54800 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757414AbXEKL1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 07:27:11 -0400
Received: by wx-out-0506.google.com with SMTP id h31so837626wxd
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 04:27:10 -0700 (PDT)
In-Reply-To: <OF5A173A00.C4FD79C5-ON652572D8.001C203E-652572D8.001D8134@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-11-05 at 10:52 +0530, Krishna Kumar2 wrote:

> I didn't try to optimize the driver to take any real advantage, I coded it
> as simply as :
> 
> top:
>       next = skb->skb_flink;
>       Original driver code here, or another option is to remove the locking
>             and put it before the "top:" above, no other changes.
>       skb = next;
>       if (skb)
>             goto top;
> This way, the diffs are minimal. However, driver experts might know of some
> tricks to optimize this, since most drivers have a hundred checks before
> sending one skb, and whether some optimization to avoid that for each skb
> is possible.
> 

You will need to at some point, no big deal in order to get things in
place first- the simple example of DMA i talked about yesterday is a
simple example. i.e you avoid kicking the DMA until you have queued all
in the ring (as Gagan pointed out, kicking the DMA is a PCI IO write)
I am sure there are gazillion others.
 

> This is a good idea, I will look at your slides to see what this exactly
> is.

I will try to post my patches updated to the latest net-2.6 kernel
before you come back on monday.

> However, even with this check, drivers will return error, eg trylock failed
> or, like the e1000 has - fifo_workaround failures. But I still think it
> will significantly reduce the failures. 

Yes, this is what i refered to as the "many tunables" and led to the
claim that you may have to re-write the whole tx path in my posting.

> Right now, I get a lot of requeue's.

requeues are a good sign ;->

cheers,
jamal

