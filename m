From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: strange tcp behavior
Date: Fri, 3 Aug 2007 16:09:20 +0400
Message-ID: <20070803120920.GA23166@2ka.mipt.ru>
References: <36758.simon.1186054739@5ec7c279.invalid> <46860.212.93.96.73.1186055105.squirrel@mail.screen.lv> <48738.simon.1186056932@5ec7c279.invalid> <46B21148.2090004@simon.arlott.org.uk> <20070802180842.GA6864@2ka.mipt.ru> <46B2293B.3020406@simon.arlott.org.uk> <20070803082517.GB25582@2ka.mipt.ru> <46956.simon.1186140106@5ec7c279.invalid> <20070803115624.GD5727@2ka.mipt.ru> <60580.simon.1186142626@5ec7c279.invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john@screen.lv, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:33453 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751878AbXHCMJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 08:09:51 -0400
Content-Disposition: inline
In-Reply-To: <60580.simon.1186142626@5ec7c279.invalid>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 03, 2007 at 01:03:46PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
> On Fri, August 3, 2007 12:56, Evgeniy Polyakov wrote:
> > On Fri, Aug 03, 2007 at 12:21:46PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
> >> Since the connection is considered closed, couldn't another socket re-use it?
> >>
> >> Socket A: Recv data (unread)
> >> Socket A: Recv RST
> >> Socket B: Reuses connection (same IPs/ports)
> >> Socket A: Close
> >>
> >> Wouldn't that disrupt socket B's use of the connection?
> >
> > Then it will drop our data, since there were no appropriate handhsake.
> 
> Couldn't the sequence numbers be close enough to make the RST valid?

It does not matter - if connection is not in synchronized state all
unrelated data is dropped, so remote side is only allowed to receive syn
flag only, anything else must be dropped. If remote side does not do
that, it violates RFC.

> -- 
> Simon Arlott

-- 
	Evgeniy Polyakov
