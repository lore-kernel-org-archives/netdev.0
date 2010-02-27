From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/7] cxgb4: Add packet queues and packet DMA code
Date: Fri, 26 Feb 2010 16:16:03 -0800
Message-ID: <20100226161603.21975b6d@nehalam>
References: <8A71B368A89016469F72CD08050AD33401359B69@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Dimitrios Michailidis" <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47669 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966469Ab0B0AQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 19:16:09 -0500
In-Reply-To: <8A71B368A89016469F72CD08050AD33401359B69@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Feb 2010 16:10:07 -0800
"Dimitrios Michailidis" <dm@chelsio.com> wrote:

> 
> 
> > -----Original Message-----
> > From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> > Sent: Friday, February 26, 2010 3:58 PM
> > To: Dimitrios Michailidis
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [PATCH 4/7] cxgb4: Add packet queues and packet DMA code
> > 
> > On Fri, 26 Feb 2010 15:35:36 -0800
> > Dimitris Michailidis <dm@chelsio.com> wrote:
> > 
> > > +
> > > +/**
> > > + *	need_skb_unmap - does the platform need unmapping of sk_buffs?
> > > + *
> > > + *	Returns true if the platfrom needs sk_buff unmapping.  The
> compiler
> > > + *	optimizes away unecessary code if this returns true.
> > > + */
> > > +static inline int need_skb_unmap(void)
> > > +{
> > > +	/*
> > > +	 * This structure is used to tell if the platfrom needs buffer
> > > +	 * unmapping by checking if DECLARE_PCI_UNMAP_ADDR defines
> anything.
> > > +	 */
> > > +	struct dummy {
> > > +		DECLARE_PCI_UNMAP_ADDR(addr);
> > > +	};
> > > +
> > > +	return sizeof(struct dummy) != 0;
> > > +}
> > > +
> > 
> > I would prefer one code path and let the compiler decide if unmap
> > should be nop; rather than this kind of trick code.
> 
> I believe this function does not generate any code, the compiler
> statically figures out the result and optimizes any conditionals that
> call it.  What option do you have in mind that would tell the compiler
> if unmap is nop?

Why do you care, let compiler decide.

-- 
