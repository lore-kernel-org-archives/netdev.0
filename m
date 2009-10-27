From: Karsten Keil <keil@b1-systems.de>
Subject: Re: [PATCH 6/9] ser_gigaset: checkpatch cleanup
Date: Tue, 27 Oct 2009 12:20:03 +0200
Message-ID: <200910271120.04597.keil@b1-systems.de>
References: <20091023-patch-gigaset-00.tilman@imap.cc> <1256518486.14711.13.camel@Joe-Laptop.home> <4AE637D8.60809@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Tilman Schmidt <tilman@imap.cc>, Joe Perches <joe@perches.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	i4ldeveloper@listserv.isdn4linux.de,
	Hansjoerg Lipp <hjlipp@web.de>,
	David Miller <davem@davemloft.net>
To: isdn4linux@listserv.isdn4linux.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753811AbZJ0Lfb@vger.kernel.org>
In-Reply-To: <4AE637D8.60809@imap.cc>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Dienstag, 27. Oktober 2009 00:59:20 Tilman Schmidt wrote:
> Am 26.10.2009 01:54 schrieb Joe Perches:
> > On Sun, 2009-10-25 at 20:30 +0100, Tilman Schmidt wrote:
> >> Duly uglified as demanded by checkpatch.pl.
> >> diff --git a/drivers/isdn/gigaset/ser-gigaset.c
> >> b/drivers/isdn/gigaset/ser-gigaset.c index 3071a52..ac3409e 100644
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

gcc should handle this subsequent  double evaluation  well enough.

> significantly more prone to easily overlooked typos which result in
> checking a different pointer in the if statement than the one that's
> actually used in the subsequent assignment.
>

Yes this may happen, but more often a = in if statements  should be a ==.

The kernel code style says only one statement per line, which implies  no 
assignments in if statements, so we should follow this.
The checkpatch.pl script  complain about these issues.

Yes sometimes in the past (while preparing some old code for kernel submit)
I was not very happy about all these rules, it take lot  time to reach zero 
reports from checkpatch.
But it make lot of sense in the long term, currently I have to debug code 
written without any code style, it is really, really painful and I need 5-10 
times  more time for simple understanding the basic function of the code.

Karsten
