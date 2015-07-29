From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [RFC PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Wed, 29 Jul 2015 08:11:48 +0200
Message-ID: <20150729061148.GB18456@unicorn.suse.cz>
References: <55B6E8AC.4060600@alliedtelesis.co.nz>
 <CALx6S361R1UeEECQn9vFDCS-wi_StoV6mekqgSK-0t-0NPvWEA@mail.gmail.com>
 <55B7F202.5050503@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>
To: Richard Laing <Richard.Laing@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46851 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107AbbG2GLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 02:11:51 -0400
Content-Disposition: inline
In-Reply-To: <55B7F202.5050503@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2015 at 09:20:02PM +0000, Richard Laing wrote:
> >> diff --git a/include/net/flow.h b/include/net/flow.h
> >> index 8109a15..d1d933d 100644
> >> --- a/include/net/flow.h
> >> +++ b/include/net/flow.h
> >> @@ -79,6 +79,10 @@ struct flowi4 {
> >>    #define fl4_ipsec_spi        uli.spi
> >>    #define fl4_mh_type        uli.mht.type
> >>    #define fl4_gre_key        uli.gre_key
> >> +
> >> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
> > Why bother making this a CONFIG, round robin is a miserable algorithm
> > anyway and nearly all the other packet steering mechanisms already use
> > a hash.
> 
> Fair enough, I will look at making it a sysctl option. I guess the 
> default can be the current behaviour.

Hm... that's an interesting question. In general, it's better to use
current behaviour as a default so that people are not surprised on
upgrade. On the other hand, it used to be per-flow  - or rather per
destination - earlier (until the routing cache removal, I believe) and
per-flow distribution is IMHO preferrable in majority of use cases. In
theory, there was a route attribute "equalize" to switch to per-packet
distribution, but it was never actually implemented, AFAIK (it was
recognized by ip and passed to kernel but ignored there).

Anyway, config option is definitely inconvenient as most users install
distribution kernels and do not configure their kernels themselves. Even
boot parameter would be better - but sysctl sounds much better. Having
both sysctl and per-route attribute would be perfect, of course.

                                                        Michal Kubecek
