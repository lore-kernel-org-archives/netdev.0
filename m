From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: An inconsistency/bug in ingress netem timestamps
Date: Wed, 15 Apr 2009 13:29:18 -0700
Message-ID: <20090415132918.7579ffa6@nehalam>
References: <20090415195022.GA3322@ami.dom.local>
	<200904151610.43980.alexandre.sidorenko@hp.com>
	<20090415202620.GB3322@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50713 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752489AbZDOU3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 16:29:24 -0400
In-Reply-To: <20090415202620.GB3322@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Apr 2009 22:26:20 +0200
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Wed, Apr 15, 2009 at 04:10:43PM -0400, Alex Sidorenko wrote:
> > On April 15, 2009 03:50:22 pm Jarek Poplawski wrote:
> > 
> > > I agree there is an inconsistency, but it seems 100 ms isn't the
> > > "right" thing to show here. It shows an internal delay added on ifb by
> > > any packet scheduler, so probably not what a user usually expects.
> > 
> > Hi Jarek,
> > 
> > thank you for your comments. Yes, I understand that it just looked OK in this 
> > case even though technically the value was not quite correct.
> > 
> > > > The strange thing is that as soon as there is any ptype_all handler
> > > > installed, skb->tstamp is updated properly. Unfortunately, my knowledge
> > > > of TC internals is not good enough to find how exactly this happens.
> > >
> > > Isn't it when act_mirred calls dev_queue_xmit with dev_queue_xmit_nit?
> > > But, as above mentioned, I doubt it's "updated properly" in this case.
> > 
> > I can see that dev_queue_xmit_nit calls net_timestamp(skb) unconditionally. I 
> > agree that to fix this properly we need to update tstamp in another place 
> > explicitly (in ifb or netem?).
> 
> Hmm... I'm not sure how "popular" is netem on ifb, but we could try
> Stephen's opinion (Cc-ed).

If you are putting on netem on ingress, the timestamps could happen before
or after the added delay. As long as it is consistent, then I have no problem
with the existing behavior; ie. it is not a bug, it just works that way.
