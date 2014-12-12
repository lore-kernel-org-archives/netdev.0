From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2 v3] ip: Simplify executing ip cmd within network
 ns
Date: Fri, 12 Dec 2014 21:26:52 +0200
Message-ID: <20141212192652.GA11063@angus-think.lan>
References: <1418337171-2792-1-git-send-email-vadim4j@gmail.com>
 <20141211172640.1afc3283@urahara>
 <20141212060436.GA876@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:47753 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965391AbaLLTgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 14:36:46 -0500
Received: by mail-la0-f53.google.com with SMTP id gm9so6494816lab.40
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2014 11:36:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141212060436.GA876@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2014 at 08:04:36AM +0200, vadim4j@gmail.com wrote:
> On Thu, Dec 11, 2014 at 05:26:40PM -0800, Stephen Hemminger wrote:
> > On Fri, 12 Dec 2014 00:32:51 +0200
> > Vadim Kochan <vadim4j@gmail.com> wrote:
> > 
> > > +
> > > +#define NETNS_RUN_DIR "/var/run/netns"
> > > +#define NETNS_ETC_DIR "/etc/netns"
> > > +
> > > +#ifndef CLONE_NEWNET
> > > +#define CLONE_NEWNET 0x40000000	/* New network namespace (lo, device, names sockets, etc) */
> > > +#endif
> > > +
> > > +#ifndef MNT_DETACH
> > > +#define MNT_DETACH	0x00000002	/* Just detach from the tree */
> > > +#endif /* MNT_DETACH */
> > > +
> > > +/* sys/mount.h may be out too old to have these */
> > > +#ifndef MS_REC
> > > +#define MS_REC		16384
> > > +#endif
> > > +
> > > +#ifndef MS_SLAVE
> > > +#define MS_SLAVE	(1 << 19)
> > > +#endif
> > > +
> > > +#ifndef MS_SHARED
> > > +#define MS_SHARED	(1 << 20)
> > > +#endif
> > > +
> > > +extern int netns_switch(char *netns);
> > > +
> > 
> > Maybe it would be cleaner to introduce a new file netns.h
> > with this and the setnetns syscall wrapper
> > 
> And MS_*/MNT_* defines to new mount.h ?
> 
> Thanks,
> 

I think it can go all together (netns + mount things) to the new
include/namespace.h header, what do you think ?

And what about netns_switch func - let it be in utils.c/utils.h or
add new lib/namespace.c which will be linked to the libutil ?

Thanks,
