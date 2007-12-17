From: "Parag Warudkar" <parag.warudkar@gmail.com>
Subject: Re: init_timer_deferrable conversion
Date: Mon, 17 Dec 2007 13:37:01 -0500
Message-ID: <82e4877d0712171037u3945f683u9d2262c938f0b772@mail.gmail.com>
References: <Pine.LNX.4.64.0712162149220.4622@mini.warudkars.net>
	 <20071217095504.b02241ee.dada1@cosmosbay.com>
	 <20071217152943.10470215.dada1@cosmosbay.com>
	 <20071217090000.64499fba@deepthought>
	 <82e4877d0712170947v45929acv92e0d34c86d82c6d@mail.gmail.com>
	 <20071217101355.7f4e6031@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Arjan van de Ven" <arjan@infradead.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:21580 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482AbXLQShF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 13:37:05 -0500
Received: by wr-out-0506.google.com with SMTP id c49so1323344wra.1
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2007 10:37:04 -0800 (PST)
In-Reply-To: <20071217101355.7f4e6031@deepthought>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 17, 2007 1:13 PM, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:
> On Mon, 17 Dec 2007 12:47:59 -0500
> "Parag Warudkar" <parag.warudkar@gmail.com> wrote:
>
>
> > On Dec 17, 2007 12:00 PM, Stephen Hemminger
> > <shemminger@linux-foundation.org> wrote:
> > > > > >
> > > > > > a) drivers/net/sky2.c - watchdog_timer. This was showing up high on
> > > > > > Powertop's list of things that cause routine wakeups from idle. After
> > > > > > converting to init_timer_deferrable() the wakeups went down and this one
> > > > > > no longer shows up in powertop's list. 25% reduction.
> > >
> > > This surprises me because it is a 1 hz timer and uses round_jiffies() in
> > > the current kernel.
> >
> > I am using the current git and I already have low wakeups per second
> > to begin with - 5-7  and out of that 25% are attributed to sky2. Not
> > sure if that matches up with the 1 hz + round_jiffies() logic.
> >
> > But is it conceptually ok to make this deferrable? I suppose yes as
> > it's just a watchdog that checks if the link is up and delaying that
> > would not make a difference?
>
> I think you are going to wake up once a second anyway, so all it
> ends up changing is the accounting. Please check with the powertop
> developers.

As I understand it the advantage of deferrable is that sky2 won't have
to wakeup the CPU just for itself.
It can be coupled with other things that need to wake up the CPU. So
hopefully this isn't just a powertop accounting fixup :)

>
> I'm fine with changing sky2, but it would be good if you could
> go through all the network drivers and fix them as well.
>

Arjan - if there is value in converting netdev watchdogs to deferrable
from a PM perpective I will fix up other drivers as well.

Thanks

Parag
