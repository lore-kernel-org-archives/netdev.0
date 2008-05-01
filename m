From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 1 May 2008 12:02:27 +0100
Message-ID: <20080501110225.GG14219@solarflare.com>
References: <20080430214845.GC14219@solarflare.com> <E1JrWFU-0001ue-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kmansley@solarflare.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:37743 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754825AbYEALDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 07:03:47 -0400
Content-Disposition: inline
In-Reply-To: <E1JrWFU-0001ue-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> > Large Receive Offload (LRO) destroys packet headers that should be
> > preserved when forwarding.  Currently it also triggers a BUG() or WARN()
> > in skb_gso_segment().  We should disable it wherever forwarding is
> > enabled, and discard LRO skbs with a warning if it is turned back on.
> 
> I don't think forwarding GSO packets is bad per se.  However,
> doing LRO on forwarded traffic is broken because it breaks the
> end-to-end connection.  So I agree that we should detect this
> but preferrably not based on the GSO flag as LRO isn't the only
> source of GSO traffic and the rest of them can be forwarded just
> fine.

My understanding is that at the points I'm adding the check, we're only
considering received skbs and gso_size will only be set if LRO was used.

I was going to raise the virtualisation issue because Kieran has been
in contact with XenSource over this and they believed LRO was not a
problem in Xen.  So long as the bridges in dom0 each connect a single
physical interface to other domains running paravirtualised Linux, this
is probably true.  But I have no idea how to "whitelist" this sort of
case.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
