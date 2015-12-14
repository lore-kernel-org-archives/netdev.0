From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv2 net-next] ipv6: allow routes to be configured with
 expire values
Date: Mon, 14 Dec 2015 19:48:01 +0800
Message-ID: <CADvbK_fxww6-EfDgdo-4e=UscsB_pvJO4z1NAPiFyujiA5xr0Q@mail.gmail.com>
References: <b813d147f9f4c938fbe4c3e0e671e88b2afcf412.1449678473.git.lucien.xin@gmail.com>
	<20151211.202157.2045048466167764855.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37513 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932179AbbLNLsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 06:48:03 -0500
Received: by igcto18 with SMTP id to18so80366156igc.0
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 03:48:02 -0800 (PST)
In-Reply-To: <20151211.202157.2045048466167764855.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> This is the wrong way to do this.
>
> Currently we only ever dump rta_cacheinfo values to the user.
>
> If we use it to set things, we have to completely consider every
> member of that structure as potentially having meaning either
> intended by the user or choosen by us in the future.
>
> Therefore it is a poor choice to start using for specifying the
> expires value, and some other mechanism such as a new RTNETLINK
> attribute, should be used for this.

we did it like this to avoid adding the new RTNETLINK attribute.
now I got your meaning, and rta_cacheinfo seems to be designed
for dumping info, not for seting info. i guess you hope we do it like:

+       if (tb[RTA_EXPIRES]) {
+               unsigned long timeout =
addrconf_timeout_fixup(nla_get_u32(tb[RTA_EXPIRES]), HZ);
+
+               if (addrconf_finite_timeout(timeout)) {
+                       cfg->fc_expires = jiffies_to_clock_t(timeout * HZ);
+                       cfg->fc_flags |= RTF_EXPIRES;
+               }
+       }

hi Hannes, we seem to go back here again, what do you think ?
