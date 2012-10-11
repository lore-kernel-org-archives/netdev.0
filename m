From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 qfq_dequeue()
Date: Thu, 11 Oct 2012 17:20:43 +0200
Message-ID: <1349968843.21172.9508.camel@edumazet-glaptop>
References: <1349687756.2707.21.camel@cr0>  <1349944709.3412.2.camel@cr0>
	 <1349967908.21172.9459.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@redhat.com>, rizzo@iet.unipi.it
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60374 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733Ab2JKPUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 11:20:46 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1058360bkc.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 08:20:45 -0700 (PDT)
In-Reply-To: <1349967908.21172.9459.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-11 at 17:05 +0200, Eric Dumazet wrote:
> On Thu, 2012-10-11 at 16:38 +0800, Cong Wang wrote:
> > On Mon, 2012-10-08 at 17:15 +0800, Cong Wang wrote:
> > > Hi, all,
> > > 
> > > We got the following kernel crash on RHEL6 and I confirmed upstream has
> > > the same problem (I didn't save this kernel log though):
> > 
> > Ok, I got the backtrace of the latest kernel, see below. Seems
> > qfq_slot_scan() in qfq_dequeue() returns something bad, 'cl' becomes
> > '0x10'.
> 
> not exactly, cl is -0x50
> 

> > 
> 
> 
> static struct qfq_class *qfq_slot_head(struct qfq_group *grp)
> {
>         return hlist_entry(grp->slots[grp->front].first,
>                            struct qfq_class, next);
> }
> 
> 
> problem is : grp->slots[grp->front].first is NULL here,
> 
> so we return RAX = -offsetof(struct qfq_class, next)
> 
> (ie -0x50 : ffffffffffffffb0)
> 
> 
> So one bit is set in full_slots while the corresponding slots[] is
> empty.
> 
> I wonder if qfq_slot_remove() is correct ?


I just realize its a 2.6.32 redhat kernel, while QFQ is a 3.0 addition.

Can you reproduce the bug on current kernel (3.6 or git tree)
