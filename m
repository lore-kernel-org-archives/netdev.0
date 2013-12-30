From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 4/11]  use ether_addr_equal_64bits
Date: Tue, 31 Dec 2013 00:13:08 +0100
Message-ID: <1388445188.18164.0.camel@jlt4.sipsolutions.net>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
	 <1388427307-8691-5-git-send-email-Julia.Lawall@lip6.fr>
	 <1388429761.4410.1.camel@jlt4.sipsolutions.net>
	 <alpine.DEB.2.02.1312302057420.2209@localhost6.localdomain6>
	 <1388438724.4573.2.camel@jlt4.sipsolutions.net>
	 <20131230215701.GA4938@khazad-dum.debian.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131230215701.GA4938-ZGHd14iZgfaRjzvQDGKj+xxZW9W5cXbT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-12-30 at 19:57 -0200, Henrique de Moraes Holschuh wrote:
> On Mon, 30 Dec 2013, Johannes Berg wrote:
> > On Mon, 2013-12-30 at 20:58 +0100, Julia Lawall wrote:
> > > > Is there any way we could catch (sparse, or some other script?) that
> > > > struct reorganising won't break the condition needed ("within a
> > > > structure that contains at least two more bytes")?
> > > 
> > > What kind of reorganizing could happen?  Do you mean that the programmer 
> > > might do at some time in the future, or something the compiler might do?
> > 
> > I'm just thinking of a programmer, e.g. changing a struct like this:
> > 
> >  struct foo {
> >    u8 addr[ETH_ALEN];
> > -  u16 dummy;
> >  };
> > 
> > for example.
> 
> That is easily resolved by:
> 
> struct foo {
> 	u8 addr[ETH_ALEN];
> 	u16 required_padding;	/* do not remove upon pain of death */
> };

That'd be a stupid waste of struct space. If anything, there should be
*only* a comment saying that at least two bytes are needed - I'd still
prefer an automated check.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
