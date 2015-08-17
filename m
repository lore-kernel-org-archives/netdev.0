From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/2] net: introduce IFF_NO_QUEUE as successor of zero
 tx_queue_len
Date: Mon, 17 Aug 2015 17:16:03 +0200
Message-ID: <20150817171603.244c36f0@redhat.com>
References: <1439485268-20953-1-git-send-email-phil@nwl.cc>
	<20150813104950.1b8346f2@urahara>
	<20150813204037.3c4e68a4@redhat.com>
	<20150813121157.5166efb1@urahara>
	<20150814084153.GI32353@orbit.nwl.cc>
	<20150817085121.419a1d28@redhat.com>
	<1439819091.7258.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, fw@strlen.de, cwang@twopensource.com,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49061 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755304AbbHQPQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 11:16:07 -0400
In-Reply-To: <1439819091.7258.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Aug 2015 06:44:51 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2015-08-17 at 08:51 +0200, Jesper Dangaard Brouer wrote:
> > On Fri, 14 Aug 2015 10:41:53 +0200 Phil Sutter <phil@nwl.cc> wrote:
> > 
> > > On Thu, Aug 13, 2015 at 12:11:57PM -0700, Stephen Hemminger wrote:
> > [...]
> > > > 
> > > > But adding a flag risks breaking external scripts.
> > > 
> > > Could you please elaborate on this? As far as I can tell, introducing a
> > > separate flag is the only solution *not* breaking existing scripts. So
> > > if you see the rub, I would like to know where exactly it is.
> > 
> > I agree with Phil.  AFAIC see this approach does not break existing
> > scripts.
> > 
> > Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > 
> 
> But, what is the long term plan ?
> 
> If long term plan is to change veth txqueuelen to 0, we said no.
> (because it is too late and this change will break some setups)

No, veth keep txqueuelen at the default 1000.  We simply add the flag
IFF_NO_QUEUE to veth. 

That result in (1) veth gets no-qdisc when using the default qdisc, and
(2) if anyone assigns another qdisc it still works.  This is backward
compatible with existing scripts.

Long term plan is to change e.g. vlan to be marked with IFF_NO_QUEUE
and don't set txqueuelen to zero (automatic falls back to default
setting).  This avoids any gotchas for users assigning a qdisc. This is
also backward compatible, with users who know to change the txqueuelen
before assigning a qdisc to a vlan.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
