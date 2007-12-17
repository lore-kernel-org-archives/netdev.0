From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: init_timer_deferrable conversion
Date: Mon, 17 Dec 2007 10:13:55 -0800
Message-ID: <20071217101355.7f4e6031@deepthought>
References: <Pine.LNX.4.64.0712162149220.4622@mini.warudkars.net>
	<20071217095504.b02241ee.dada1@cosmosbay.com>
	<20071217152943.10470215.dada1@cosmosbay.com>
	<20071217090000.64499fba@deepthought>
	<82e4877d0712170947v45929acv92e0d34c86d82c6d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Parag Warudkar" <parag.warudkar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42000 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753474AbXLQSPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 13:15:12 -0500
In-Reply-To: <82e4877d0712170947v45929acv92e0d34c86d82c6d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Dec 2007 12:47:59 -0500
"Parag Warudkar" <parag.warudkar@gmail.com> wrote:

> On Dec 17, 2007 12:00 PM, Stephen Hemminger
> <shemminger@linux-foundation.org> wrote:
> > > > >
> > > > > a) drivers/net/sky2.c - watchdog_timer. This was showing up high on
> > > > > Powertop's list of things that cause routine wakeups from idle. After
> > > > > converting to init_timer_deferrable() the wakeups went down and this one
> > > > > no longer shows up in powertop's list. 25% reduction.
> >
> > This surprises me because it is a 1 hz timer and uses round_jiffies() in
> > the current kernel.
> 
> I am using the current git and I already have low wakeups per second
> to begin with - 5-7  and out of that 25% are attributed to sky2. Not
> sure if that matches up with the 1 hz + round_jiffies() logic.
> 
> But is it conceptually ok to make this deferrable? I suppose yes as
> it's just a watchdog that checks if the link is up and delaying that
> would not make a difference?

I think you are going to wake up once a second anyway, so all it
ends up changing is the accounting. Please check with the powertop
developers.

I'm fine with changing sky2, but it would be good if you could
go through all the network drivers and fix them as well.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
