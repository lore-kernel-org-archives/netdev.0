From: Gerald Britton <gbritton@doomcom.org>
Subject: Re: [RFC] Wireless extensions rethink
Date: Wed, 16 Jun 2004 15:06:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616190613.GA25743@fog.sekrit.org>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com> <40CF263E.70009@home.nl> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <20040616152808.GA6270@fog.sekrit.org> <1087408417.25912.79.camel@sfeldma-mobl2.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gertjan van Wingerde <gwingerde@home.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
Content-Disposition: inline
In-Reply-To: <1087408417.25912.79.camel@sfeldma-mobl2.dsl-verizon.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 16, 2004 at 10:53:38AM -0700, Scott Feldman wrote:
> On Wed, 2004-06-16 at 08:28, Gerald Britton wrote:
> > A few comments below.
> > [snip]
> > > +	char	essid[32];	/* ESSID; any = NULL string */
> > 
> > This isn't sufficient as you can have \0 bytes in the ESSID so treating it
> > as a null-terminated string is probably not ideal.  Also the spec specifies
> > 32 characters as a max, but the 802.11 management IE's could support upto
> > 255 character essid's, this probably needs a little extra thought.
> 
> Ok, how about
> 
> 	u8	essid[32];	/* ESSID; any = all zeros */
> 
> On the size, include/linux/wireless.h has it defined as 32:
> 
> /* Maximum size of the ESSID and NICKN strings */
> #define IW_ESSID_MAX_SIZE       32

IMHO, this is a flaw in the current wireless extensions.  Your idea doesn't
provide any way to determine the actual size of the data.  ssids of \0\0 and
\0\0\0 differ.  I like Vladimir Kondratiev's suggestion of defining things
in terms of info elements (IE's).  This is how they get encoded in the frames
sent over the air.

> > > +	char	sec_key[32];	/* Security mode encryption key */
> > 
> > Similar here, is 32 characters worth of "key" enough here.
> 
> include/linux/wireless.h has it defined as 32:
> 
> /* Maximum size of the encoding token in bytes */
> #define IW_ENCODING_TOKEN_MAX   32      /* 256 bits (for now) */

IMO, simply following the wireless extentions is probably the wrong way to
approach this, there is the opportunity to redesign things to better fit
the actual needs of a generic ieee 802.11 stack in the kernel, and of the
existing and likely future drivers. The current wireless extentions in many
areas attempt to be over generic with interfaces which I've never seen a
device actually implement to others whre the API ends up limiting you (like
the ssid and key setting here).

> > Also a quick thought to settings many drivers have in their iwpriv
> > commands such as operating modes .11b/.11a/.11g/auto.  A survey of a bunch
> > of drivers is probably worth doing to collect where the previous wireless
> > extentions didn't really fit their needs.
> 
> So far we've only looked at the standard settings, but you're right, we
> should move commonly used private settings over to the standard set. 
> There are some drivers (i.e. prism54) that use module params that are
> duplicates of the standard settings.  These need cleaning up as well.
> 
> -scott

Yeah.  a handful of examples i can think of off the top of my head:
antenna selection (diversity), beacon intervals, roaming settings,
promiscuous mode within a bssid vs. fully promiscous receive (this
one is probably highly dependant on generic 802.11 stack support).

				-- Gerald
