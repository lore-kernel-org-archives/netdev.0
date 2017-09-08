From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH iproute2 2/2] lib/libnetlink: update rtnl_talk to support
 malloc buff at run time
Date: Fri, 8 Sep 2017 21:26:16 +0800
Message-ID: <20170908132616.GT5465@leo.usersys.redhat.com>
References: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
 <1504865697-27274-3-git-send-email-liuhangbin@gmail.com>
 <20170908110652.GU2399@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35384 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755884AbdIHN02 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 09:26:28 -0400
Received: by mail-pg0-f67.google.com with SMTP id q68so1312343pgq.2
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 06:26:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170908110652.GU2399@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 08, 2017 at 01:06:52PM +0200, Phil Sutter wrote:
> Hi Hangbin,
> 
> On Fri, Sep 08, 2017 at 06:14:57PM +0800, Hangbin Liu wrote:
> [...]
> > diff --git a/genl/ctrl.c b/genl/ctrl.c
> > index 448988e..699657b 100644
> > --- a/genl/ctrl.c
> > +++ b/genl/ctrl.c
> > @@ -55,6 +55,7 @@ int genl_ctrl_resolve_family(const char *family)
> >  	};
> >  	struct nlmsghdr *nlh = &req.n;
> >  	struct genlmsghdr *ghdr = &req.g;
> > +	struct nlmsghdr *answer = NULL;
> 
> I don't think it's necessary to assign NULL here or in any of the other
> cases.

OK
> 
> >  	if (rtnl_open_byproto(&rth, 0, NETLINK_GENERIC) < 0) {
> >  		fprintf(stderr, "Cannot open generic netlink socket\n");
> > @@ -63,19 +64,19 @@ int genl_ctrl_resolve_family(const char *family)
> >  
> >  	addattr_l(nlh, 128, CTRL_ATTR_FAMILY_NAME, family, strlen(family) + 1);
> >  
> > -	if (rtnl_talk(&rth, nlh, nlh, sizeof(req)) < 0) {
> > +	if (rtnl_talk(&rth, nlh, &answer) < 0) {
> 
> I didn't check, but it's likely that at least in some cases 'nlh'
> contains some buffer space to hold the answer (if it will be larger than
> the input). If so, this could be dropped since the buffer is no longer
> reused.

Yes, I will remove the buffer.

Thanks
Hangbin
