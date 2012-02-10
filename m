From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH] iproute2: Add flag to indicate extended dump info
Date: Fri, 10 Feb 2012 16:43:39 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F886EA@ORSMSX106.amr.corp.intel.com>
References: <20120210151804.4175.12859.stgit@gitlad.jf.intel.com>
 <20120210084121.3b922f1d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11808 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754811Ab2BJQn5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 11:43:57 -0500
In-Reply-To: <20120210084121.3b922f1d@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Friday, February 10, 2012 8:41 AM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [RFC PATCH] iproute2: Add flag to indicate extended dump info
> 
> On Fri, 10 Feb 2012 07:18:05 -0800
> Greg Rose <gregory.v.rose@intel.com> wrote:
> 
> > Add flag to the ip link dump command to indicate to the kernel that
> > the application is requesting the extended interface information such
> > as VFs.  The kernel will take this flag as an implicit indication that
> > the application has allocated a 16K or larger buffer, which is what
> > the 'ip' command in fact does.
> >
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > ---
> >
> >  include/linux/netlink.h |    1 +
> >  lib/libnetlink.c        |    2 +-
> >  2 files changed, 2 insertions(+), 1 deletions(-)
> >
> > diff --git a/include/linux/netlink.h b/include/linux/netlink.h
> > index 5c4f087..f913797 100644
> > --- a/include/linux/netlink.h
> > +++ b/include/linux/netlink.h
> > @@ -59,6 +59,7 @@ struct nlmsghdr {
> >  #define NLM_F_MATCH	0x200	/* return all matching	*/
> >  #define NLM_F_ATOMIC	0x400	/* atomic GET		*/
> >  #define NLM_F_DUMP	(NLM_F_ROOT|NLM_F_MATCH)
> > +#define NLM_F_EXT	0x800   /* Get extended interface info such as VFs
> */
> >
> >  /* Modifiers to NEW request */
> >  #define NLM_F_REPLACE	0x100	/* Override existing		*/
> > diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> > index c581e11..f29da3d 100644
> > --- a/lib/libnetlink.c
> > +++ b/lib/libnetlink.c
> > @@ -99,7 +99,7 @@ int rtnl_wilddump_request(struct rtnl_handle *rth, int
> family, int type)
> >  	memset(&req, 0, sizeof(req));
> >  	req.nlh.nlmsg_len = sizeof(req);
> >  	req.nlh.nlmsg_type = type;
> > -	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
> > +	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST|NLM_F_EXT;
> >  	req.nlh.nlmsg_pid = 0;
> >  	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
> >  	req.g.rtgen_family = family;
> >
> 
> Make sure and test backwards compatibility with older kernels.
> It should be fine as long as the flag is ignored now.

We'll do that as soon as I get an indication that this associated kernel patch might actually fly.  I've been shot down in flames and wreckage once already so I'm not placing any bets.

Thanks,

- Greg
