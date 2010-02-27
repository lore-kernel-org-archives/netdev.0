From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/7] cxgb4: Add packet queues and packet DMA code
Date: Fri, 26 Feb 2010 17:31:04 -0800
Message-ID: <20100226173104.2de7195c@nehalam>
References: <8A71B368A89016469F72CD08050AD33401359B6A@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Dimitrios Michailidis" <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51329 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966798Ab0B0BbW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 20:31:22 -0500
In-Reply-To: <8A71B368A89016469F72CD08050AD33401359B6A@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Feb 2010 16:52:10 -0800
"Dimitrios Michailidis" <dm@chelsio.com> wrote:

> 
> 
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org
> [mailto:netdev-owner@vger.kernel.org]
> > On Behalf Of Stephen Hemminger
> > Sent: Friday, February 26, 2010 4:16 PM
> > To: Dimitrios Michailidis
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [PATCH 4/7] cxgb4: Add packet queues and packet DMA code
> > 
> > On Fri, 26 Feb 2010 16:10:07 -0800
> > "Dimitrios Michailidis" <dm@chelsio.com> wrote:
> > 
> > >
> > >
> > > > -----Original Message-----
> > > > From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> > > > Sent: Friday, February 26, 2010 3:58 PM
> > > > To: Dimitrios Michailidis
> > > > Cc: netdev@vger.kernel.org
> > > > Subject: Re: [PATCH 4/7] cxgb4: Add packet queues and packet DMA
> code
> > > >
> > > > On Fri, 26 Feb 2010 15:35:36 -0800
> > > > Dimitris Michailidis <dm@chelsio.com> wrote:
> > > >
> > > > > +
> > > > > +/**
> > > > > + *	need_skb_unmap - does the platform need unmapping of
> sk_buffs?
> > > > > + *
> > > > > + *	Returns true if the platfrom needs sk_buff unmapping.
> The
> > > compiler
> > > > > + *	optimizes away unecessary code if this returns true.
> > > > > + */
> > > > > +static inline int need_skb_unmap(void)
> > > > > +{
> > > > > +	/*
> > > > > +	 * This structure is used to tell if the platfrom needs
> buffer
> > > > > +	 * unmapping by checking if DECLARE_PCI_UNMAP_ADDR
> defines
> > > anything.
> > > > > +	 */
> > > > > +	struct dummy {
> > > > > +		DECLARE_PCI_UNMAP_ADDR(addr);
> > > > > +	};
> > > > > +
> > > > > +	return sizeof(struct dummy) != 0;
> > > > > +}
> > > > > +
> > > >
> > > > I would prefer one code path and let the compiler decide if unmap
> > > > should be nop; rather than this kind of trick code.
> > >
> > > I believe this function does not generate any code, the compiler
> > > statically figures out the result and optimizes any conditionals
> that
> > > call it.  What option do you have in mind that would tell the
> compiler
> > > if unmap is nop?
> > 
> > Why do you care, let compiler decide.
> 
> I want the compiler to decide but I must be missing something.  How is
> the compiler going to decide?  The purpose of this code is to tell the
> compiler if unmapping is nop.  Does it have another way to tell?

I looked closer, it is all tied up with deferred skb unmapping and that
code looks inherited from cxgb3. Not sure why you need to hold to skb for
so long: some offload requirement? Anyway keep it they way it is..

-- 
