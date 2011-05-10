From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC V2 PATCH] rtnetlink: Add method to calculate dump info
 data size
Date: Tue, 10 May 2011 06:03:02 +0200
Message-ID: <1305000182.3050.50.camel@edumazet-laptop>
References: <20110509222629.8689.77365.stgit@gitlad.jf.intel.com>
	 <1304995413.3050.19.camel@edumazet-laptop>
	 <20110509201705.409f6d39@nehalam>
	 <1304999127.3050.40.camel@edumazet-laptop>
	 <20110509205626.19dede92@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	bhutchings@solarflare.com, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64350 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab1EJEDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 00:03:11 -0400
Received: by wwa36 with SMTP id 36so6428692wwa.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 21:03:10 -0700 (PDT)
In-Reply-To: <20110509205626.19dede92@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 mai 2011 =C3=A0 20:56 -0700, Stephen Hemminger a =C3=A9crit=
 :
> What happens is dump iterates over the table and puts entries into
> skb. When space is exhausted in skb the iterator stops and records th=
e
> key of the where to restart.

Exactly : We would increase min_dump_alloc at this point, and not fully
recompute it at each round ;)

Problem is we could return an empty answer if first device ever dumped
in "ip link" would be a 'large one' and min_dump_alloc not yet
increased, so "ip link" would consider table is empty ?

Thats why I suggested to increase min_dump_alloc() when bloated^W drive=
r
is loaded.



