From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v6 15/16] cipso: Add support for native local labeling and fixup mapping names
Date: Wed, 1 Oct 2008 13:05:04 -0400
Message-ID: <200810011305.04872.paul.moore@hp.com>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125730.17132.74360.stgit@flek.lan> <alpine.LRH.1.10.0810012003170.6732@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.1.10.0810012003170.6732@tundra.namei.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 October 2008 6:09:30 am James Morris wrote:
> On Tue, 16 Sep 2008, Paul Moore wrote:
> > +/* Base length of the local tag (non-standard tag).
> > + *  Tag definition (may change between kernel versions)
> > + *
> > + * 0          8          16         24         32
> > + * +----------+----------+----------+----------+
> > + * | 10000000 | 00001000 | unused (zero fill)  |
> > + * +----------+----------+----------+----------+
> > + * |   32-bit secid value (host byte order)    |
> > + * +----------+----------+----------+----------+
> > + *
> > + */
> > +#define CIPSO_V4_TAG_LOC_BLEN         8
> > +
> >
> > +static int cipso_v4_gentag_loc(const struct cipso_v4_doi *doi_def,
> > +			       const struct netlbl_lsm_secattr *secattr,
> > +			       unsigned char *buffer,
> > +			       u32 buffer_len)
> > +{
> > +	if (!(secattr->flags & NETLBL_SECATTR_SECID))
> > +		return -EPERM;
> > +
> > +	buffer[0] = 0x80;
> > +	buffer[1] = 0x08;
> > +	*(u32 *)&buffer[4] = secattr->attr.secid;
> > +
> > +	return 8;
> > +}
>
> Macros would be nice for these ...

I assume you mean the "0x80" and "0x08" constants and not the function 
itself?  I ask because I remember reading that (macros == evil) because 
of the lack of parameter type checking.

> ... and why specify zero filling?  (Setting and testing that would be
> wasted cycles, if you enforced it). 

Better alignment within the IP option field, the goal being to try and 
get the secid aligned on a 32bit boundary.  However, it just occurred 
to me that by adding the two octets of padding I've actually pushed it 
out of alignment (I forgot about the obligatory IP option type and 
length octets).

Man I hate IPv4 options, what a parsing nightmare ...

-- 
paul moore
linux @ hp
