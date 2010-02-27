From: "Dimitrios Michailidis" <dm@chelsio.com>
Subject: RE: [PATCH 4/7] cxgb4: Add packet queues and packet DMA code
Date: Fri, 26 Feb 2010 16:52:10 -0800
Message-ID: <8A71B368A89016469F72CD08050AD33401359B6A@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3231 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966740Ab0B0AvJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 19:51:09 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Stephen Hemminger
> Sent: Friday, February 26, 2010 4:16 PM
> To: Dimitrios Michailidis
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH 4/7] cxgb4: Add packet queues and packet DMA code
> 
> On Fri, 26 Feb 2010 16:10:07 -0800
> "Dimitrios Michailidis" <dm@chelsio.com> wrote:
> 
> >
> >
> > > -----Original Message-----
> > > From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> > > Sent: Friday, February 26, 2010 3:58 PM
> > > To: Dimitrios Michailidis
> > > Cc: netdev@vger.kernel.org
> > > Subject: Re: [PATCH 4/7] cxgb4: Add packet queues and packet DMA
code
> > >
> > > On Fri, 26 Feb 2010 15:35:36 -0800
> > > Dimitris Michailidis <dm@chelsio.com> wrote:
> > >
> > > > +
> > > > +/**
> > > > + *	need_skb_unmap - does the platform need unmapping of
sk_buffs?
> > > > + *
> > > > + *	Returns true if the platfrom needs sk_buff unmapping.
The
> > compiler
> > > > + *	optimizes away unecessary code if this returns true.
> > > > + */
> > > > +static inline int need_skb_unmap(void)
> > > > +{
> > > > +	/*
> > > > +	 * This structure is used to tell if the platfrom needs
buffer
> > > > +	 * unmapping by checking if DECLARE_PCI_UNMAP_ADDR
defines
> > anything.
> > > > +	 */
> > > > +	struct dummy {
> > > > +		DECLARE_PCI_UNMAP_ADDR(addr);
> > > > +	};
> > > > +
> > > > +	return sizeof(struct dummy) != 0;
> > > > +}
> > > > +
> > >
> > > I would prefer one code path and let the compiler decide if unmap
> > > should be nop; rather than this kind of trick code.
> >
> > I believe this function does not generate any code, the compiler
> > statically figures out the result and optimizes any conditionals
that
> > call it.  What option do you have in mind that would tell the
compiler
> > if unmap is nop?
> 
> Why do you care, let compiler decide.

I want the compiler to decide but I must be missing something.  How is
the compiler going to decide?  The purpose of this code is to tell the
compiler if unmapping is nop.  Does it have another way to tell?
