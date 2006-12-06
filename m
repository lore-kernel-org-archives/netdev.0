From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: Kernel header changes break glibc build
Date: Wed, 6 Dec 2006 14:57:30 +0100
Message-ID: <20061206135730.GM9556@sunsite.mff.cuni.cz>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk> <1165148731.12649.51.camel@pmac.infradead.org> <20061204091341.GM8693@postel.suug.ch> <1165410114.5253.218.camel@pmac.infradead.org> <20061206134308.GL9556@sunsite.mff.cuni.cz> <1165413068.5253.223.camel@pmac.infradead.org>
Reply-To: Jakub Jelinek <jakub@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ulrich Drepper <drepper@redhat.com>, Thomas Graf <tgraf@suug.ch>,         "Joseph S. Myers" <joseph@codesourcery.com>, netdev@vger.kernel.org,         libc-alpha@sourceware.org, akpm@osdl.org,         "David S. Miller" <davem@davemloft.net>
Return-path: <libc-alpha-return-19601-glibc-alpha=m.gmane.org@sourceware.org>
To: David Woodhouse <dwmw2@infradead.org>
Content-Disposition: inline
In-Reply-To: <1165413068.5253.223.camel@pmac.infradead.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 06, 2006 at 01:51:07PM +0000, David Woodhouse wrote:
> On Wed, 2006-12-06 at 14:43 +0100, Jakub Jelinek wrote:
> > 
> > +/* 2.6.19 kernel headers helpfully removed some macros and
> > +   moved lots of stuff into new headers, some of which aren't
> > +   included by linux/rtnetlink.h.  */
> > +
> > +#ifndef IFA_MAX
> > +struct ifaddrmsg
> > +{
> > +  uint8_t ifa_family;
> > +  uint8_t ifa_prefixlen;
> > +  uint8_t ifa_flags;
> > +  uint8_t ifa_scope;
> > +  uint32_t ifa_index;
> > +};
> > +
> > +enum
> > +{
> > +  IFA_UNSPEC,
> > +  IFA_ADDRESS,
> > +  IFA_LOCAL,
> > +  IFA_LABEL,
> > +  IFA_BROADCAST,
> > +  IFA_ANYCAST,
> > +  IFA_CACHEINFO,
> > +  IFA_MULTICAST
> > +};
> > +#endif
> > +
> > +#ifndef IFA_F_SECONDARY
> > +# define IFA_F_SECONDARY       0x01
> > +# define IFA_F_TEMPORARY       IFA_F_SECONDARY
> > +# define IFA_F_HOMEADDRESS     0x10
> > +# define IFA_F_DEPRECATED      0x20
> > +#endif
> 
> This much is still available from the new <linux/if_addr.h> -- you could
> include that directly instead of copying it.

Yes, but as I said, I'd need to add configure checks for that, using
#include <linux/if_addr.h>
alone breaks build with older headers.
glibc so far managed to build without a single configure check for header
existence, this would be the first place where something like that is
needed.

	Jakub
