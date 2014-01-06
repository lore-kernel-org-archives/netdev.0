From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 4/11]  use ether_addr_equal_64bits
Date: Mon, 6 Jan 2014 13:48:02 +0300
Message-ID: <20140106104802.GN30234@mwanda>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
 <1388427307-8691-5-git-send-email-Julia.Lawall@lip6.fr>
 <1388429761.4410.1.camel@jlt4.sipsolutions.net>
 <alpine.DEB.2.02.1312302057420.2209@localhost6.localdomain6>
 <1388438724.4573.2.camel@jlt4.sipsolutions.net>
 <20131230215701.GA4938@khazad-dum.debian.net>
 <1388445188.18164.0.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	Julia Lawall <julia.lawall@lip6.fr>,
	kernel-janitors@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1388445188.18164.0.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 31, 2013 at 12:13:08AM +0100, Johannes Berg wrote:
> On Mon, 2013-12-30 at 19:57 -0200, Henrique de Moraes Holschuh wrote:
> > On Mon, 30 Dec 2013, Johannes Berg wrote:
> > > On Mon, 2013-12-30 at 20:58 +0100, Julia Lawall wrote:
> > > > > Is there any way we could catch (sparse, or some other script?) that
> > > > > struct reorganising won't break the condition needed ("within a
> > > > > structure that contains at least two more bytes")?
> > > > 
> > > > What kind of reorganizing could happen?  Do you mean that the programmer 
> > > > might do at some time in the future, or something the compiler might do?
> > > 
> > > I'm just thinking of a programmer, e.g. changing a struct like this:
> > > 
> > >  struct foo {
> > >    u8 addr[ETH_ALEN];
> > > -  u16 dummy;
> > >  };
> > > 
> > > for example.
> > 
> > That is easily resolved by:
> > 
> > struct foo {
> > 	u8 addr[ETH_ALEN];
> > 	u16 required_padding;	/* do not remove upon pain of death */
> > };
> 
> That'd be a stupid waste of struct space. If anything, there should be
> *only* a comment saying that at least two bytes are needed - I'd still
> prefer an automated check.
> 

This is the sort of thing where Smatch is probably the right tool.  I'll
let you know how it turns out.

My guess is that it would be rare to run into this bug in real life.
Most structs have 4 or 8 byte alignment and most times the addr is not
at the end of the struct.  But I also agree that this function should
only be used in a fast path.

regards,
dan carpenter
