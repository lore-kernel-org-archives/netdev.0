From: "Laurent Chavey" <chavey@google.com>
Subject: Re: AF_PACKET how to get the original netdev from a packet received from a bonded master
Date: Mon, 23 Apr 2007 12:03:30 -0700
Message-ID: <97949e3e0704231203k7a70905xa81f57c47f3132@mail.gmail.com>
References: <97949e3e0704181605v39e24bh18ac278adc8b823f@mail.gmail.com>
	 <20070418.162523.68157230.davem@davemloft.net>
	 <41b516cb0704181652o6a05b570t511ee23373a0b3ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Chris Leech" <chris.leech@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:49849 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754133AbXDWTDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 15:03:51 -0400
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id l3NJ3fjf017878
	for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 12:03:41 -0700
Received: from ug-out-1314.google.com (uga36.prod.google.com [10.66.1.36])
	by zps77.corp.google.com with ESMTP id l3NJ3LFE001756
	for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 12:03:30 -0700
Received: by ug-out-1314.google.com with SMTP id 36so10571uga
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 12:03:30 -0700 (PDT)
In-Reply-To: <41b516cb0704181652o6a05b570t511ee23373a0b3ac@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you for the pointer, I am looking at the patch ad
see if it help. In my case, that will do the trick, but as mentioned
by Dave it may not have its place in a general distro.

Perso I would rather "cloning" <-- do not flame me, it is not my intent to
                                                 open a long thread :-)
          the skb received on the bond and pass the clone + original skb
          to the tap. This gives a "symetrical" behavior to the tap...

Some of the point made for LLDP etc... may not require this
patch if one adds the processing as a protocol.

Thank you.

On 4/18/07, Chris Leech <chris.leech@gmail.com> wrote:
> On 4/18/07, David Miller <davem@davemloft.net> wrote:
> > From: "Laurent Chavey" <chavey@google.com>
> > Date: Wed, 18 Apr 2007 16:05:27 -0700
> >
> > > When using PF_PACKET socket with bonded interfaces, there is no
> > > way to get the slave interface (physical interface) the packet was
> > > actually received on.
> >
> > That's right.
> >
> > There isn't a real good solution to this problem either.
> > Decapsulation can happen to arbitrary levels, how many
> > devices should we remember and how to do the reference
> > counting on that correctly?
> >
> > As such, I don't think this will ever be provided.
>
> PJ Waskiewicz posted a patch that introduced a new socket option for
> PF_PACKET sockets to return the orig_dev->ifindex instead of
> dev->ifindex in sockaddr_ll.  He posted the patch on  March 8th.
>
> http://marc.info/?l=linux-kernel&m=117340678318939&w=2
>
> He also re-posted it on March 19th, at which point you (Dave) told him
> that it was in your backlog and he didn't need to keep resending it.
>
> To me it's seem like a decent opt-in solution for applications that
> might care, without changing existing behavior.  Laurent, would that
> change help you?  Dave, is there a reason you can see why this
> wouldn't work?
>
> - Chris
>
