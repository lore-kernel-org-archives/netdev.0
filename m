From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: Reply: [PATCH iproute2] ip-link: remove warning message
Date: Fri, 5 Feb 2016 09:50:00 +0800
Message-ID: <000501d15fb7$86d847b0$9488d710$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Stephen Hemminger'" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:3939 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbcBEBtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 20:49:52 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, 21 Jan 2016 02:23:49 +0000
> Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:
> 
> > the warning was:
> > iproute.c:301:12: warning: 'val' may be used uninitialized in this
> > function [-Wmaybe-uninitialized]
> >    features &= ~RTAX_FEATURE_ECN;
> >             ^
> > iproute.c:575:10: note: 'val' was declared here
> >    __u32 val;
> > 	  ^
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > ---
> >  ip/iproute.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/ip/iproute.c b/ip/iproute.c index d5e3ebe..afe70e1 100644
> > --- a/ip/iproute.c
> > +++ b/ip/iproute.c
> > @@ -572,7 +572,7 @@ int print_route(const struct sockaddr_nl *who,
> struct nlmsghdr *n, void *arg)
> >  			mxlock =
> *(unsigned*)RTA_DATA(mxrta[RTAX_LOCK]);
> >
> >  		for (i=2; i<= RTAX_MAX; i++) {
> > -			__u32 val;
> > +			__u32 val = 0U;
> >
> >  			if (mxrta[i] == NULL)
> >  				continue;
> 
> Your compiler is doing bad dependency analysis.
> There is not really a bug here.
> 
> It would still be best to initialize to keep broken compilers from causing
> warning.

Yes, it's not really a bug here. This variable is set by all means.  This
patch just want to remove the warning. 

Thanks,
Shengju
