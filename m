From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/4] [RFC] virtio-net: Improve small packet performance
Date: Thu, 5 May 2011 13:12:29 +0300
Message-ID: <20110505101229.GA28690@redhat.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com>
 <20110504144622.GA15823@redhat.com>
 <OFAEA8C363.C13C507B-ON65257886.0051F71F-65257886.0052217F@in.ibm.com>
 <20110504212359.GA21446@redhat.com>
 <OF2E0182A1.3818A07E-ON65257887.00225EE8-65257887.002C000C@in.ibm.com>
 <20110505090439.GD17647@redhat.com>
 <OF057406D7.B63B52F4-ON65257887.00344787-65257887.003532EF@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753510Ab1EEKMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 06:12:49 -0400
Content-Disposition: inline
In-Reply-To: <OF057406D7.B63B52F4-ON65257887.00344787-65257887.003532EF@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2011 at 03:13:43PM +0530, Krishna Kumar2 wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 05/05/2011 02:34:39 PM:
> 
> > > It shows that 2.9% of the time, the 1 jiffy was not enough
> > > to free up space in the txq.
> >
> > How common is it to free up space in *less than* 1 jiffy?
> 
> True,

Sorry, which statement do you say is true? That interrupt
after less than 1 jiffy is common?

> but the point is that the space freed is just
> enough for 43 entries, keeping it lower means a flood
> of (psuedo) stop's and restart's.
> 
> > > That could also mean that we
> > > had set xmit_restart just before jiffies changed. But the
> > > average free capacity when we *resumed* xmits is:
> > > Sum of slots / (Good + Bad) = 43.
> > >
> > > So the delay of 1 jiffy helped the host clean up, on average,
> > > just 43 entries, which is 16% of total entries. This is
> > > intended to show that the guest is not sitting idle waiting
> > > for the jiffy to expire.
> >
> > OK, nice, this is exactly what my patchset is trying
> > to do, without playing with timers: tell the host
> > to interrupt us after 3/4 of the ring is free.
> > Why 3/4 and not all of the ring? My hope is we can
> > get some parallelism with the host this way.
> > Why 3/4 and not 7/8? No idea :)
> >
> > > > > > I can post it, mind testing this?
> > > > >
> > > > > Sure.
> > > >
> > > > Just posted. Would appreciate feedback.
> > >
> > > Do I need to apply all the patches and simply test?
> > >
> > > Thanks,
> > >
> > > - KK
> >
> > Exactly. You can also try to tune the threshold
> > for interrupts as well.
> 
> Could you send me (privately) the entire virtio-net/vhost
> patch in a single file? It will help me quite a bit :)
> Either attachment or inline is fine.
> 
> thanks,
> 
> - KK

Better yet, here they are in git:

git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next-event-idx-v1
git://git.kernel.org/pub/scm/linux/kernel/git/mst/qemu-kvm.git virtio-net-event-idx-v1


-- 
MST
