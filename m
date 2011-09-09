From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Memory leak in ip_dst_cache
Date: Sat, 10 Sep 2011 00:08:45 +0200
Message-ID: <1315606125.2606.19.camel@edumazet-laptop>
References: <1315544674.20226.YahooMailNeo@web113902.mail.gq1.yahoo.com>
	 <1315546223.5410.23.camel@edumazet-laptop>
	 <1315593553.98279.YahooMailNeo@web113904.mail.gq1.yahoo.com>
	 <1315596786.2606.3.camel@edumazet-laptop>
	 <1315601283.91185.YahooMailNeo@web113908.mail.gq1.yahoo.com>
	 <1315604820.2606.13.camel@edumazet-laptop>
	 <1315605497.25052.YahooMailNeo@web113916.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Kumar S <ps2kumar@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:51496 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517Ab1IIWIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 18:08:52 -0400
Received: by wwn22 with SMTP id 22so836554wwn.1
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2011 15:08:50 -0700 (PDT)
In-Reply-To: <1315605497.25052.YahooMailNeo@web113916.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 septembre 2011 =C3=A0 14:58 -0700, Kumar S a =C3=A9crit =
:
> I agree, 3 MB is not a concern. But actually this is exceeding, we ar=
e
> seeing more than 1200000 objects in a span of 24 hours, which is clos=
e
> to 300 MB.

Hmm, please include netdev in your mails.

Then there is something else.

Maybe a timer bug preventing dst_gc_task() to make its duty.

>  Other tasks require somewhere around 200 MB+. When it reaches this
> number, the board reboots. In lab we could simulate this. That is how
> I'm trying to understand the problem. I'm injecting around 10k routes=
,
> and waiting for them to ageout.
> =20

I dont know, you could try disable IP route cache.

On recent (2.6.29+) kernels, thats very easy

# Disable Ip route cache (negative value in rebuild_count)
echo 3000000000 >/proc/sys/net/ipv4/rt_cache_rebuild_count

On an old kernel, you probably need to patch your kernel, or backport
commit 1080d709fb9d8cd43 (net: implement emergency route cache rebulds
when gc_elasticity is exceeded)
