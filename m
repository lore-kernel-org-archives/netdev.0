From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH] netfilter: xt_condition: add security capability
 support
Date: Tue, 24 Aug 2010 10:00:20 +0300
Message-ID: <1282633220.7198.123.camel@powerslave>
References: <1282567801-2673-1-git-send-email-luciano.coelho@nokia.com>
	 <AANLkTi=2H+ytOQU9nC_dRp_GB5Sy1831VY14oW=YSOrG@mail.gmail.com>
	 <1282570935.7198.5.camel@powerslave>
	 <alpine.LNX.2.01.1008231628010.21000@obet.zrqbmnf.qr>
	 <1282589101.7198.28.camel@powerslave>
	 <alpine.LNX.2.01.1008232052170.31619@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ext Changli Gao <xiaosuo@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:60313 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261Ab0HXHAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 03:00:51 -0400
In-Reply-To: <alpine.LNX.2.01.1008232052170.31619@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-23 at 20:58 +0200, ext Jan Engelhardt wrote:
> On Monday 2010-08-23 20:45, Luciano Coelho wrote:
> >> But it looks as strange as the Yama code attempt.
> >
> >What is so strange about it? Is it because it's possible to set the
> >capability requirement from modprobe arguments? The capability check
> >already exists in at least in nfnetlink, where it checks for received
> >messages for the CAP_NET_ADMIN capability.  Is it strange because we're
> >checking for the capability when someone tries to write to a file?
> 
> It is strange that you check this capability from a module focused on
> packet handling. For lack of a better example, it's as if you tried
> to check the uid of the file, the latter of which is better left to
> the routines in fs/.

Okay, thanks for the explanation! I'll have to figure something else out
then.

What I don't understand is that I see lots of components, which have
nothing to do with security, making this kind of checks.  Most of them
(if not all) are checking for input from userspace where they provide
their own interfaces (eg. ioctl calls, netlink messages).

I can see that ip_tables checks for this capability when it gets "set"
socket calls.  Now, with the xt_condition, we're opening a new route
from userspace to the kernel and I think it might be a good idea to
protect that too.

It's kind of useless to protect someone without CAP_NET_ADMIN from
creating a condition rule if it is possible to change the condition from
userspace without any capability protection.


> >>  This is the one time 
> >> where I would personally be looking into SELinux, or perhaps SMACK if 
> >> the former is too complex, to whether _t'ing off procfs is possible.
> >
> >Yeah, but it's not up to me to decide this.  We have one entire team
> >dedicated to figuring out how to ensure "security" in our device.  It
> >was that team who advised us to protect this file by checking for
> >CAP_NET_ADMIN.
> 
> You can do whatever you want with your product. I am just saying this
> does not look like kernel material, and I suppose it won't go well
> with the maintainers up the chain either.

Yeah, my company can do whatever they want with the product.  But my
role here is to work with upstream, so if you guys think that what I'm
doing is total bulls*it, I'll have to go back to the drawing board and
restart my work ;)

Again, I must stress that I really appreciate your comments and help.  I
know I can get good advice from people who are millions of times more
experienced in this area than I am (and yes, that's *you* ;) -- and this
is one of the various reasons I send my patches to netfilter-devel in
the first place.  Another reason is that I want to contribute my work
(however shitty it is) to an eventual benefit for the community as a
whole. :)

-- 
Cheers,
Luca.

