From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: Re: [PATCH 0/8] Cleanup/fix the sk_alloc() call
Date: Wed, 31 Oct 2007 11:15:05 -0200
Message-ID: <20071031131505.GD3962@ghostprotocols.net>
References: <472885B1.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53771 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753564AbXJaNPM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 09:15:12 -0400
Content-Disposition: inline
In-Reply-To: <472885B1.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Oct 31, 2007 at 04:40:01PM +0300, Pavel Emelyanov escreveu:
> The sk_alloc() function suffers from two problems:
> 1 (major). The error path is not clean in it - if the security
>    call fails, the net namespace is not put, if the try_module_get
>    fails  additionally the security context is not released;
> 2 (minor). The zero_it argument is misleading, as it doesn't just 
>    zeroes it, but performs some extra setup. Besides this argument 
>    is used only in one place - in the sk_clone().
> 
> So this set fixes these problems and performs some additional
> cleanup.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

for the series:

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Haven't tested, but it looks straightforward and conceptually sound,
thanks for improving the sk_prot infrastructure! :-)

Now we have just to make all the other protocols fill in the missing
sk->sk_prot-> methods (converting what is there now in socket->ops) so
that we can kill socket->ops and eliminate one level of indirection :-P

- Arnaldo
