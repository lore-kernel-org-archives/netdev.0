From: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: hardware time stamping with optional structs in data area
Date: Wed, 28 Jan 2009 10:52:13 +0100
Message-ID: <1233136333.26507.38.camel@pohly-MOBL>
References: <20090128090821.GA15770@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090128090821.GA15770-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-01-28 at 11:08 +0200, Herbert Xu wrote:
> Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
> >
> > True - at this time. But what if this extension mechanism turns out to
> > be useful and we end up with more optional structures? I was hoping that
> > this might be the case and thus tried to make it easy to add more
> > structures.
> 
> You're putting the extension in the skb->end area, right?

Right.

> How big are the time stamps? If they're not that big, why don't
> we put it into the shinfo structure itself? For the common case,
> we have plenty of space due to kmalloc padding anyway.

Two 64 bit fields have to be added for time stamps plus 3 bits for flags
(for time stamping instructions, currently in skb_shared_tx).

Putting that into shinfo should work fine. I thought extending that
structure with information that isn't needed for all packets was as bad
as extending sk_buff itself. If that isn't the case, then extending
shinfo definitely is the simplest solution.

Bye, Patrick


--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
