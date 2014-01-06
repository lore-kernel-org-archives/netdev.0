From: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
Subject: Re: [PATCH 4/11]  use ether_addr_equal_64bits
Date: Mon, 6 Jan 2014 10:09:20 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1401061007160.2079@hadrien>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>   <1388427307-8691-5-git-send-email-Julia.Lawall@lip6.fr>   <1388429761.4410.1.camel@jlt4.sipsolutions.net>   <alpine.DEB.2.02.1312302057420.2209@localhost6.localdomain6>  
 <1388438724.4573.2.camel@jlt4.sipsolutions.net>   <20131230215701.GA4938@khazad-dum.debian.net>   <1388445188.18164.0.camel@jlt4.sipsolutions.net>  <1388445422.26796.38.camel@joe-AO722>  <alpine.DEB.2.02.1312310726540.1930@localhost6.localdomain6>
 <52C2E8BA.6000800@candelatech.com>  <alpine.DEB.2.10.1312311704320.2074@hadrien>  <52C2F056.1020005@candelatech.com>  <alpine.DEB.2.10.1312311732080.2074@hadrien> <1388999147.5891.2.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>,
	Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1388999147.5891.2.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 6 Jan 2014, Johannes Berg wrote:

> On Tue, 2013-12-31 at 17:40 +0100, Julia Lawall wrote:
>
> > > If nothing else, then some run-time code that calculates the offset off
> > > and asserts if it is broken in module initialization or similar might
> > > be good enough.
> >
> > Could be OK.  Something right in or after the structure declaration would
> > be nicest.
>
> I don't think you can put a BUILD_BUG_ON() into the structure
> declaration (it's code, not declarations), but I think you could just
> put
>
> BUILD_BUG_ON(sizeof(struct foo) - offsetof(struct foo, addr) < 8);
>
> with the user(s?) and that should catch the scenario I was worrying
> about?

OK, thanks.  That is what I had in mind.  But I was hoping to be able to
put it with the structure.  Perhaps there is a way to make a macro that
expands to a dummy function that contains the BUILD_BUG_ON?  But I guess
that would waste space?

I think that 8 should be 16?

julia
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
