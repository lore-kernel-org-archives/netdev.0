From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 01:42:51 +0200
Message-ID: <20150429234251.GB3416@salvia>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <CAHA+R7NWeOLTjgAd9xQNcVP=snNOiH0aLy0FyUWzqdH+gVbJ9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58172 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324AbbD2XiW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2015 19:38:22 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7NWeOLTjgAd9xQNcVP=snNOiH0aLy0FyUWzqdH+gVbJ9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 02:53:58PM -0700, Cong Wang wrote:
> On Wed, Apr 29, 2015 at 11:53 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> > index 2274e72..23b57da 100644
> > --- a/net/sched/Kconfig
> > +++ b/net/sched/Kconfig
> > @@ -312,6 +312,7 @@ config NET_SCH_PIE
> >  config NET_SCH_INGRESS
> >         tristate "Ingress Qdisc"
> >         depends on NET_CLS_ACT
> > +       select NETFILTER_INGRESS
> >         ---help---
> >           Say Y here if you want to use classifiers for incoming packets.
> >           If unsure, say Y.
> 
> 
> So now it impossible to compile ingress Qdics without netfilters...
> 
> (I know you moved them into net/core/, but still they are netfilter API's.)

This is only one single file that only contains the very basic hook
infrastructure, this does not depend on the layer 3.

> Why do we have to mix different layers? IOW, why not just keep TC at L2
> and netfilters at L3 even just w.r.t. API?

I think that used to be true in the iptables days... The nftables
infrastructure is flexible and extensible enough to satisfy the needs
of other network layers.
