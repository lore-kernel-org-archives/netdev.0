From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: lots of cpu time spent in skb_copy_bits() in net-next with	small
 mtu
Date: Wed, 17 Jun 2009 08:46:56 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0906170831020.28187@melkinkari.cs.Helsinki.FI>
References: <20090612161320.GB4290@neterion.com>
 <Pine.LNX.4.64.0906122248450.31625@melkinkari.cs.Helsinki.FI>
 <1245180000.7150.6.camel@Maple>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243445-2057851837-1245217616=:28187"
Cc: Benjamin LaHaise <ben.lahaise@neterion.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60747 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657AbZFQFqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 01:46:55 -0400
In-Reply-To: <1245180000.7150.6.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243445-2057851837-1245217616=:28187
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Tue, 16 Jun 2009, John Dykstra wrote:

> On Fri, 2009-06-12 at 22:57 +0300, Ilpo Järvinen wrote:
> > On Fri, 12 Jun 2009, Benjamin LaHaise wrote:
> > 
> > > Just a heads up: something in net-next is resulting in lots of cpu time 
> > > being spent in skb_copy_bits() (called from tcp_collapse()) when an ethernet 
> > > interface mtu is lowered to 576 on the source and dest machines running 
> > > netperf.  This behaviour does not appear in 2.6.29.  I'll try to bisect 
> > > it this weekend.
> > 
> > I'd suggest somebody goes through DaveM's abstraction patch 915219441d56 
> > (I'm totally out of time so somebody else has to do it if a timely 
> > solution is desired)... It was quite messy on those parts and I already 
> > found one issue from it (2df9001edc3) and wouldn't be too surprised if 
> > there would be some more lurking around... 
> 
> I couldn't find anything wrong with tcp_prune_queue() and its helpers as
> they appear in today's net-next.
> 
> Take that with a grain of salt if you wish--I'm going to go take a
> couple grains of aspirin.

:-) Thanks for taking a look.

While I took a very short view on it earlier I notice that handling of the 
case when head is at the last skb and tail is at the end of queue was 
changed (without mention in the commit message whether it was 
intentionally) in the Dave's change (we used to exit at skb == tail while 
we don't necessarily do that anymore but take the additional checks that 
are made inside the loop ub tcp_collapse()). It would be nice if Dave 
would split that kind of complex transformation into more easily 
verifiable changes, even if the intermediate form itself would not remain 
in the final form, as is it's rather hard to track it all :-).

I'm not sure if that change is significant though as one might view it as 
the opposite, ie., that the previous was unintented early exit since we 
wouldn't collapse bloated skb in the end but who knows... ...But I'm yet 
to really _understand_ everything that is going on there.


-- 
 i.
---696243445-2057851837-1245217616=:28187--
