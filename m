From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Memory leak in ip_dst_cache
Date: Fri, 09 Sep 2011 23:47:00 +0200
Message-ID: <1315604820.2606.13.camel@edumazet-laptop>
References: <1315544674.20226.YahooMailNeo@web113902.mail.gq1.yahoo.com>
	 <1315546223.5410.23.camel@edumazet-laptop>
	 <1315593553.98279.YahooMailNeo@web113904.mail.gq1.yahoo.com>
	 <1315596786.2606.3.camel@edumazet-laptop>
	 <1315601283.91185.YahooMailNeo@web113908.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kumar S <ps2kumar@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34535 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795Ab1IIVrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 17:47:05 -0400
Received: by wwf5 with SMTP id 5so1636325wwf.1
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2011 14:47:04 -0700 (PDT)
In-Reply-To: <1315601283.91185.YahooMailNeo@web113908.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 septembre 2011 =C3=A0 13:48 -0700, Kumar S a =C3=A9crit =
:
> Hi Eric,
> I did not flush those routes explicitly. They are flushed out
> automatically by calling "rt_run_flush". It inturn calls rt_free(),
> but __cache_free() never gets called after that. Basically, I have 51=
2
> MBytes of memory on board. I want to restrict the cache to around 64k=
,
> with max_size. But if I do that due to this leak, TCP/IP communicatio=
n
> stops working when it reaches 64k.
> =20

Your dsts use about 3Mb of memory out of 512Mb. Its certainly not the
reason of the failures you have.

Its not a leak.

All "in use" dst are queued in dst_gc, check net/core/dst.c for details=
=2E
