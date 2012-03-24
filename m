From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] iwlwifi: fix skb truesize underestimation
Date: Sat, 24 Mar 2012 09:12:09 -0700
Message-ID: <1332605529.3487.16.camel@edumazet-laptop>
References: <1332507112.4858.12.camel@edumazet-laptop>
	 <20120323.143826.1042705555491529895.davem@davemloft.net>
	 <1332528919.2516.2.camel@edumazet-glaptop>
	 <1332547547.2516.132.camel@edumazet-glaptop>
	 <1332548545.2516.134.camel@edumazet-glaptop>
	 <1332548986.2516.139.camel@edumazet-glaptop>
	 <1332603328.27767.11.camel@wwguy-huron>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50810 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815Ab2CXQMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2012 12:12:12 -0400
Received: by pbcun15 with SMTP id un15so3724926pbc.19
        for <netdev@vger.kernel.org>; Sat, 24 Mar 2012 09:12:12 -0700 (PDT)
In-Reply-To: <1332603328.27767.11.camel@wwguy-huron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 24 mars 2012 =C3=A0 08:35 -0700, Guy, Wey-Yi a =C3=A9crit :
> Hi Eric,
>=20
> On Fri, 2012-03-23 at 17:29 -0700, Eric Dumazet wrote:
> > By default, iwlwifi uses order-1 pages (8 KB) to store incoming fra=
mes,
> > but doesnt say so in skb->truesize.
> >=20
> > This makes very possible to exhaust kernel memory since these skb e=
vade
> > normal socket memory accounting.
> >=20
> > As struct ieee80211_hdr is going to be pulled before calling IP sta=
ck,
> > there is no need to use dev_alloc_skb() to reserve NET_SKB_PAD byte=
s.
> > alloc_skb() is ok in this driver, allowing more tailroom.
> >=20
> > Pull beginning of frame in skb header, in the hope we can reuse ord=
er-1
> > pages in the driver immediately for small frames and reduce their
> > truesize to the minimum (linear skbs)
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Wey-Yi Guy <wey-yi.w.guy@intel.com>
> > Cc: "John W. Linville" <linville@tuxdriver.com>
> > Cc: Neal Cardwell <ncardwell@google.com>
> > ---
>=20
> Is it ok I pull your patch into our internal tree first for regressio=
n
> testing, once the test is done, I will push your patch along with all
> our other patches together to wireless-next(John Linville).
>=20
> By doing so, first, we know the patch is not breaking any functionali=
ty
> for all the devices(legacy/new), second, it is easier for us to sync-=
up
> with all the other changes we are making now.
>=20

I am absolutely fine with this plan, thanks a lot !

BTW, why order-1 pages are the default on this driver ?
