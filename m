From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 6/9] ser_gigaset: checkpatch cleanup
Date: Mon, 26 Oct 2009 17:14:54 -0700
Message-ID: <1256602494.29938.13.camel@Joe-Laptop.home>
References: <20091023-patch-gigaset-00.tilman@imap.cc>
	 <20091023-patch-gigaset-06.tilman@imap.cc>
	 <1256518486.14711.13.camel@Joe-Laptop.home>  <4AE637D8.60809@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1082 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754786AbZJ0AOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 20:14:50 -0400
In-Reply-To: <4AE637D8.60809@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-10-27 at 00:59 +0100, Tilman Schmidt wrote:
> Am 26.10.2009 01:54 schrieb Joe Perches:
> > On Sun, 2009-10-25 at 20:30 +0100, Tilman Schmidt wrote:
> >> Duly uglified as demanded by checkpatch.pl.
> >> diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
> >> index 3071a52..ac3409e 100644
> >> --- a/drivers/isdn/gigaset/ser-gigaset.c
> >> +++ b/drivers/isdn/gigaset/ser-gigaset.c
> >> @@ -164,9 +164,15 @@ static void gigaset_modem_fill(unsigned long data)
> >>  {
> >>  	struct cardstate *cs = (struct cardstate *) data;
> >>  	struct bc_state *bcs;
> >> +	struct sk_buff *nextskb;
> >>  	int sent = 0;
> >>  
> >> -	if (!cs || !(bcs = cs->bcs)) {
> >> +	if (!cs) {
> >> +		gig_dbg(DEBUG_OUTPUT, "%s: no cardstate", __func__);
> >> +		return;
> >> +	}
> >> +	bcs = cs->bcs;
> >> +	if (!bcs) {
> >>  		gig_dbg(DEBUG_OUTPUT, "%s: no cardstate", __func__);
> >>  		return;
> >> 	}
> > 
> > perhaps:
> > 	if (!cs || !cs->bcs) {
> > 		gig_dbg(DEBUG_OUTPUT, "%s: no cardstate", __func__);
> > 		return;
> > 	}
> > 	bcs = cs->bcs;
> 
> That would evaluate cs->bcs twice, and is also, in my experience,
> significantly more prone to easily overlooked typos which result in
> checking a different pointer in the if statement than the one that's
> actually used in the subsequent assignment.

The other is to duplicate the gig_dbg function as you've done.
Also prone to typos and more code as well.

> >> @@ -404,16 +412,20 @@ static void gigaset_device_release(struct device *dev)
> >>  static int gigaset_initcshw(struct cardstate *cs)
> >>  {
> >>  	int rc;
> >> +	struct ser_cardstate *scs;
> >>  
> >> -	if (!(cs->hw.ser = kzalloc(sizeof(struct ser_cardstate), GFP_KERNEL))) {
> >> +	scs = kzalloc(sizeof(struct ser_cardstate), GFP_KERNEL);
> >> +	if (!scs) {
> >>  		pr_err("out of memory\n");
> >>  		return 0;
> >>  	}
> >> +	cs->hw.ser = scs;
> > 
> > Why not no temporary and just:
> > 
> > 	cs->hw.ser = kzalloc...
> > 	if (!cs->hw.ser)
> 
> For the same reasons as above.

I believe the checkpatch recommended form is:

	foo = func();
	if ([!]foo) {
		handle_error()...
	}

as you've used in all the other conversions.

No big deal or difference, but I think what I
suggested is more kernel style normal.

cheers, Joe

