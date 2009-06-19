From: Nicholas Van Orton <turanammo@gmail.com>
Subject: Re: can we reuse an skb
Date: Fri, 19 Jun 2009 15:41:20 +0530
Message-ID: <b9e8fcbd0906190311k1db4653bm1d560743faa4ded1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jon_zhou@agilent.com, radhamohan_ch@yahoo.com,
	netdev@vger.kernel.org
To: Peter Chacko <peterchacko35@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:43172 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584AbZFSKLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 06:11:18 -0400
Received: by pxi27 with SMTP id 27so1690108pxi.33
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2009 03:11:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-06-19 at 12:51 +0530, Peter Chacko wrote:
Radha,
>
> skb memory is coming from slab allocation pool, which itself are
> re-usable pools. kmalloc(ATOMIC) on these object caches don't incur
> much penalty as think for a case when it does memory
> allocation/de-allocation. So the intelligence you want to put in the
> driver is already done by slab layer. But if you want to add some
> thing like per-flow ring-buffers, optimized for a point-to-point link
> or similar purpose, you can have a driver level cache .

Does this mean that when skb buffer has been allocated using
dev_alloc_skb(), filled with received data and passed to the upper
layers
the kernel would automatically do the task of releasing this buffer
without the user calling dev_kfree_skb()? I once got
KERNEL: assertion (!atomic_read(&skb->users)) failed at net/core/dev.c
errors when trying
to free them using dev_kfree_skb()

Could this be cause I did not wait until netif_rx_completed() was called?

Regards,
Nicholas




>
> thanks
>
> On Fri, Jun 19, 2009 at 12:21 PM, <jon_zhou@agilent.com> wrote:
> > I am also thinking about this...
> >
> > i.e.pcnet32.c
> > seems the skb will be claimed to be unuseful(mark some bits) in the device driver, than it will be recycled in the softirq handler,
> >
> > that means unable to reuse it, unless modidy the driver.
> >
> > Regards,
> > zhou rui
> >
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Radha Mohan
> > Sent: Friday, June 19, 2009 2:47 PM
> > To: netdev@vger.kernel.org
> > Subject: can we reuse an skb
> >
> >
> > Hi,
> >
> > For an ethernet driver, we need to allocate some pool of SKBs for receiving packets. Is there any way we can reuse the same SKBs without the need to re-allocate in atomic every time one has been used up for netif_rx().
> >
> > Any pointers will be helpful.
> >
> > -- Mohan
> >
> >
> >      ICC World Twenty20 England &#39;09 exclusively on YAHOO! CRICKET http://cricket.yahoo.com
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
