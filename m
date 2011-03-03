From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: inetpeer with create==0
Date: Thu, 3 Mar 2011 13:30:03 +0800
Message-ID: <AANLkTimwaUaC7Xu2djSNR9k98sYbSM0V88sCAc34R6Ac@mail.gmail.com>
References: <20110302.204545.193730647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40626 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab1CCFaY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 00:30:24 -0500
Received: by fxm17 with SMTP id 17so767098fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 21:30:23 -0800 (PST)
In-Reply-To: <20110302.204545.193730647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2011 at 12:45 PM, David Miller <davem@davemloft.net> wro=
te:
>
>
> I looked at the generic radix tree implementation, and it supports
> full RCU lookups in parallel with insert/delete. =A0It handles the ra=
ce
> case without the relookup under lock because it creates fixed paths
> to "slots" where nodes live using shifts and masks. =A0So if a path
> to a slot ever existed, it will always exist.
>
> Take a look at lib/radix-tree.c and include/linux/radix-tree.h if
> you are curious.
>
> I think we should do something similar for inetpeer. =A0Currently we
> cannot just use the existing generic radix-tree code because it only
> supports indexes as large as "unsigned long" and we need to handle
> 128-bit ipv6 addresses.

I am just wondering why we need a trie(radix tree) here, we don't have
to do LPM since the lengths of the keys are always fixed(ether 4 or
16). Maybe a hash table is enough and simpler, and it is RCU
compatible.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
