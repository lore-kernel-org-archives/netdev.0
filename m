From: Leandro Lucarella <luca@llucax.com.ar>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Tue, 19 Oct 2010 19:03:14 -0300
Message-ID: <20101019220314.GI8781@llucax.com.ar>
References: <4CBCD429.8090306@windriver.com>
	<20101018234547.GA5703@hmsreliant.think-freely.org>
	<20101019021657.GZ8781@llucax.com.ar>
	<20101019.011649.71113115.davem@davemloft.net>
	<20101019110452.GA14410@hmsreliant.think-freely.org>
	<20101019131936.GB8781@llucax.com.ar>
	<20101019201841.GC14410@hmsreliant.think-freely.org>
	<20101019204312.GH8781@llucax.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20101019204312.GH8781@llucax.com.ar>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Leandro Lucarella, el 19 de octubre a las 17:43 me escribiste:
> Neil Horman, el 19 de octubre a las 16:18 me escribiste:
> > Hey all-
> > 	Heres what I have so far.  Dave as a heads up please don't apply this
> > yet.  I'd like to go over it a bit more and be sure of the implications here
> > before I post it for inclusion officially.  I wanted Leandro to have a copy
> > though so he could confirm functionality for us.  Leandro, This patch lets me
> > pass the tipc test code for TIPC 1.6 that you posted earlier this morning.  If
> > you could confirm that it works for you that would be grand.  While your doing
> > that, I want to read over the spec for TIPC and make sure that I'm not breaking
> > anything new with this patch.
> 
> Thanks for the quick response. I didn't tried the patch yet, but I think
> spotted an error:
> 
> > diff --git a/include/linux/tipc.h b/include/linux/tipc.h
> > index 181c8d0..d8de884 100644
> > --- a/include/linux/tipc.h
> > +++ b/include/linux/tipc.h
> > @@ -127,9 +127,10 @@ static inline unsigned int tipc_node(__u32 addr)
> >   * TIPC topology subscription service definitions
> >   */
> >  
> > -#define TIPC_SUB_SERVICE     	0x00  	/* Filter for service availability    */
> > -#define TIPC_SUB_PORTS     	0x01  	/* Filter for port availability  */
> > +#define TIPC_SUB_SERVICE     	0x01  	/* Filter for service availability    */
> > +#define TIPC_SUB_PORTS     	0x02  	/* Filter for port availability  */
> >  #define TIPC_SUB_CANCEL         0x04    /* Cancel a subscription         */
> > +#define TIPC_SUB_MASK		(TIPC_SUB_SERVICE|TIPC_SUB_PORTS|TIPC_SUB_CANCEL)
> >  
> >  #define TIPC_WAIT_FOREVER	~0	/* timeout for permanent subscription */
> >  
> 
> The values of TIPC_SUB_SERVICE and TIPC_SUB_PORTS seem to be swapped
> compared to the old (TIPC 1.6) values:
> #define TIPC_SUB_PORTS     	0x01  	/* filter for port availability */
> #define TIPC_SUB_SERVICE     	0x02  	/* filter for service availability */
> 
> You might missed this error when trying the code I posted earlier (which
> BTW are the official TIPC demos) because the change of behaviour when
> using TIPC_SUB_SERVICE and TIPC_SUB_PORTS is very subtle (the former
> reports only the first published port name that matches, and the later
> all the published ports that match).

Also, I'm surprised the TIPC 1.6 demo program worked for you, as I don't
see any translation from the old TIPC_SUB_SERVICE value (2) to the new
one (0, or the absence of the TIPC_SUB_PORTS flag). I guess if this
subscription should be sent through the wire and should comply with
TIPC 2.0, filter & 2 should be 0.

Also, without such translation, I don't see how TIPC_SUB_SERVICE doesn't
trigger a subscription rejection with this check:

	if ((sub->filter && (sub->filter != TIPC_SUB_PORTS)) ||
			(sub->seq.lower > sub->seq.upper)) {
		warn("Subscription rejected, illegal request\n");

But if you tried the TIPC 1.6 demo and it worked, I guess I'm definitely
missing something (as I'm not familiar with TIPC code at all).

Anyway, I'll try the patch tomorrow morning and tell you how it went,
but I thought I should point out those things just in case.

Thanks.

-- 
Leandro Lucarella (AKA luca)                     http://llucax.com.ar/
----------------------------------------------------------------------
GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
----------------------------------------------------------------------
Be nice to nerds
Chances are you'll end up working for one

------------------------------------------------------------------------------
Download new Adobe(R) Flash(R) Builder(TM) 4
The new Adobe(R) Flex(R) 4 and Flash(R) Builder(TM) 4 (formerly 
Flex(R) Builder(TM)) enable the development of rich applications that run
across multiple browsers and platforms. Download your free trials today!
http://p.sf.net/sfu/adobe-dev2dev
