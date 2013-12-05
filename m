From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] vti: remove GRE_KEY flag for vti tunnel
Date: Thu, 5 Dec 2013 11:51:43 +0100
Message-ID: <20131205105143.GU31491@secunet.com>
References: <1386146917-2951-1-git-send-email-liuhangbin@gmail.com>
 <529F2430.9050906@6wind.com>
 <20131205084727.GT31491@secunet.com>
 <20131205094708.GQ1258@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	network dev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53917 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475Ab3LEKvq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 05:51:46 -0500
Content-Disposition: inline
In-Reply-To: <20131205094708.GQ1258@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 05:47:08PM +0800, Hangbin Liu wrote:
> On Thu, Dec 05, 2013 at 09:47:27AM +0100, Steffen Klassert wrote:
> > 
> > I've already metntioned that I'am a bit disappointed on how the gre
> > keys and flags are used with vti. But I fear we need to keep it
> > as it is for now, because it would at least change the behaviour
> > of iproute2 if we remove the flags.
> 
> I submit this patch just beacuse iproute2 will return fail when we modify vti
> parameters. Code here
> 
> ip/iptunnel.c#L226:
>         if (p->iph.protocol == IPPROTO_IPIP || p->iph.protocol == IPPROTO_IPV6) {
>                 if ((p->i_flags & GRE_KEY) || (p->o_flags & GRE_KEY)) {
>                         fprintf(stderr, "Keys are not allowed with ipip and sit tunnels\n");
>                         return -1;
>                 }
>         }
> 
> So should we modify iproute2 or kernel code?

Update iproute2 to allow GRE_KEY if the VTI_ISVTI flag is set.

The handling of vti keys inside the kernel needs to be redesigned too,
but this requires a concept such that the existing userspace API still
works.
