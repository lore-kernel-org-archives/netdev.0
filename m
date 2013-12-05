From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH] vti: remove GRE_KEY flag for vti tunnel
Date: Thu, 5 Dec 2013 17:47:08 +0800
Message-ID: <20131205094708.GQ1258@localhost.localdomain>
References: <1386146917-2951-1-git-send-email-liuhangbin@gmail.com>
 <529F2430.9050906@6wind.com>
 <20131205084727.GT31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	network dev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:52761 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154Ab3LEJrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 04:47:14 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so25673895pbc.33
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 01:47:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131205084727.GT31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 09:47:27AM +0100, Steffen Klassert wrote:
> On Wed, Dec 04, 2013 at 01:46:40PM +0100, Christophe Gouault wrote:
> > Hello Hangbin,
> > 
> > vti interfaces precisely need an o_key to be configured (it must be set
> > to the mark of ipsec policies attached to this interface). Consequently,
> > this flag must not be removed.
> > 
> 
> Why do we need to set these flags in vti_tunnel_ioctl()? All we do
> here, is to cheat userspace. The userspace should set these flags
> to configure the tunnel. Please note that we completely ignore
> the flags from userspace, instead we set our own flags.
> 
> I think the only reason why we set these flags here, is to make iproute2
> to print the i_key/o_key.
> 
> I've already metntioned that I'am a bit disappointed on how the gre
> keys and flags are used with vti. But I fear we need to keep it
> as it is for now, because it would at least change the behaviour
> of iproute2 if we remove the flags.

I submit this patch just beacuse iproute2 will return fail when we modify vti
parameters. Code here

ip/iptunnel.c#L226:
        if (p->iph.protocol == IPPROTO_IPIP || p->iph.protocol == IPPROTO_IPV6) {
                if ((p->i_flags & GRE_KEY) || (p->o_flags & GRE_KEY)) {
                        fprintf(stderr, "Keys are not allowed with ipip and sit tunnels\n");
                        return -1;
                }
        }

So should we modify iproute2 or kernel code?
-- 

Thanks & Best Regards
Hangbin Liu <liuhangbin@gmail.com>
