From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Fri, 07 Jul 2006 10:00:23 +0200
Message-ID: <44AE1497.6010904@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>	 <1150292693.5197.1.camel@jzny2>	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>	 <1151000966.5392.34.camel@jzny2>	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>	 <449C06E3.3090406@trash.net>	 <1151282720.4210.46.camel@ras.pc.brisbane.lube>	 <449FC0AF.1050904@trash.net> <44A0CE01.4010109@stuart.id.au>	 <44AA6D25.9000707@trash.net> <1152146376.4215.59.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:6839 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S1751097AbWGGIA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 04:00:26 -0400
To: Russell Stuart <russell@stuart.id.au>
In-Reply-To: <1152146376.4215.59.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell Stuart wrote:
> Unfortunately you do things in the wrong order for ATM.
> See: http://mailman.ds9a.nl/pipermail/lartc/2006q1/018314.html
> for an overview of the problem, and then the attached email for
> a detailed description of how the current patch addresses it.
> It is a trivial fix.

Actually that was the part I didn't understand, you keep talking
(also in that comment in tc_core.c) about an "unknown overhead".
What is that and why would it be unknown? The mail you attached
is quite long, is there an simple example that shows what you
mean?

> As I said earlier, RTAB and STAB contain the same numbers,
> just scaled differently.  The ATM patch stuffed around with
> RTAB.  With your patch in place it will have to do the same 
> exactly the same thing with STAB - because RTAB and STAB
> carry the same data.  So to me the two patches seem
> orthogonal.

Yes. As I said in the beginning of this thread, we could still
do the RTAB thing for qdiscs that support it. But since the
visible size should be the same for all qdiscs (including child
ones) we need to do the initial calculation anyway, so I don't
see any purpose in still adjusting the rate tables and using
skb->len instead of using the adjusted size.

> One observation is the size optimisation you applied to STAB, 
> making it variable length, could also be applied to RTAB.  
> In fact it should be.  Then they would be identical, apart 
> from the scaling.  Even the lookup operation (performed in
> qdisc_init_len in your patch) would be identical.

We can do that. I'm not attached to the size tables :)

> However, now you lot have made me go away and think, I have
> another idea on how to attack this.  Perhaps it will be
> more palatable to you.  It would replace RTAB and STAB with
> a 28 byte structure for most protocol stacks - well all I can
> think of off the top of my head, anyway.  RTAB would have to
> remain for backwards compatibility, of course.

Can you describe in more detail?
