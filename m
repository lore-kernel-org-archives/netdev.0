From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH] vti: remove GRE_KEY flag for vti tunnel
Date: Fri, 6 Dec 2013 00:15:44 +0800
Message-ID: <20131205161544.GS1258@localhost.localdomain>
References: <1386146917-2951-1-git-send-email-liuhangbin@gmail.com>
 <529F2430.9050906@6wind.com>
 <20131205084727.GT31491@secunet.com>
 <20131205094708.GQ1258@localhost.localdomain>
 <20131205105143.GU31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	network dev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36608 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949Ab3LEQPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 11:15:48 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so24884949pdj.36
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 08:15:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131205105143.GU31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 11:51:43AM +0100, Steffen Klassert wrote:
> On Thu, Dec 05, 2013 at 05:47:08PM +0800, Hangbin Liu wrote:
> > On Thu, Dec 05, 2013 at 09:47:27AM +0100, Steffen Klassert wrote:
> > > 
> > > I've already metntioned that I'am a bit disappointed on how the gre
> > > keys and flags are used with vti. But I fear we need to keep it
> > > as it is for now, because it would at least change the behaviour
> > > of iproute2 if we remove the flags.
> > 
> > I submit this patch just beacuse iproute2 will return fail when we modify vti
> > parameters. Code here
> > 
> > ip/iptunnel.c#L226:
> >         if (p->iph.protocol == IPPROTO_IPIP || p->iph.protocol == IPPROTO_IPV6) {
> >                 if ((p->i_flags & GRE_KEY) || (p->o_flags & GRE_KEY)) {
> >                         fprintf(stderr, "Keys are not allowed with ipip and sit tunnels\n");
> >                         return -1;
> >                 }
> >         }
> > 
> > So should we modify iproute2 or kernel code?
> 
> Update iproute2 to allow GRE_KEY if the VTI_ISVTI flag is set.

OK, I will resubmit a patch for iproute2

> 
> The handling of vti keys inside the kernel needs to be redesigned too,
> but this requires a concept such that the existing userspace API still
> works.

-- 

Thanks & Best Regards
Hangbin Liu <liuhangbin@gmail.com>
