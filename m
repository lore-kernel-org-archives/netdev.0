From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] sch_netem: Remove classful functionality
Date: Mon, 3 Nov 2008 09:06:30 -0800
Message-ID: <20081103090630.40b645d2@extreme>
References: <20081031132010.GA18895@ff.dom.local>
	<20081102.003700.198708146.davem@davemloft.net>
	<20081103082926.GA4698@ff.dom.local>
	<490EDE79.6070500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57063 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754798AbYKCRGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 12:06:32 -0500
In-Reply-To: <490EDE79.6070500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 Nov 2008 12:20:25 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Jarek Poplawski wrote:
> > On Sun, Nov 02, 2008 at 12:37:00AM -0700, David Miller wrote:
> >> From: Jarek Poplawski <jarkao2@gmail.com>
> >> Date: Fri, 31 Oct 2008 13:20:10 +0000
> >>
> >> Jarek, I applied this patch and your second one to net-next-2.6
> >>
> >> But I did this only because I trust that you will address Stephen's
> >> feedback wrt. making existing netem functionality available in
> >> some way.
> >>
> >> Otherwise I'll have to revert these changes.
> > 
> > Hmm... I thought there was kind of RFC for this, and it looked like
> > Patrick's idea won 100% of votes, but I'm not good in counting...
> > 
> > http://marc.info/?l=linux-netdev&m=122469801712438&w=2
> > http://marc.info/?l=linux-netdev&m=122469674709761&w=2
> > 
> > Anyway, IMHO adding TBF etc. functionalities to tfifo doesn't make
> > much sense, and if they are really needed it's better to revert
> > these patches and chose one of the other ways of doing reorder
> > proposed in this earlier thread.
> 
> Whats wrong with simply using TBF as parent qdisc of netem?

It works but does something slightly different.

   netem inside TBF is like long delay network followed by choke on last hop
   TBF inside netem was like choke on uplink followed by long delay network.

Since most users use the for network evaluation, and the standard for
network evaluation is dummynet; I plan to add dummynet compatiable
rate control.
