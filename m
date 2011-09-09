From: Kumar S <ps2kumar@yahoo.com>
Subject: Re: Memory leak in ip_dst_cache
Date: Fri, 9 Sep 2011 15:53:45 -0700 (PDT)
Message-ID: <1315608825.98066.YahooMailNeo@web113914.mail.gq1.yahoo.com>
References: <1315544674.20226.YahooMailNeo@web113902.mail.gq1.yahoo.com>  <1315546223.5410.23.camel@edumazet-laptop>  <1315593553.98279.YahooMailNeo@web113904.mail.gq1.yahoo.com>  <1315596786.2606.3.camel@edumazet-laptop>  <1315601283.91185.YahooMailNeo@web113908.mail.gq1.yahoo.com>  <1315604820.2606.13.camel@edumazet-laptop>  <1315605497.25052.YahooMailNeo@web113916.mail.gq1.yahoo.com> <1315606125.2606.19.camel@edumazet-laptop>
Reply-To: Kumar S <ps2kumar@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm27-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.232]:20868 "HELO
	nm27-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759458Ab1IIWyq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Sep 2011 18:54:46 -0400
In-Reply-To: <1315606125.2606.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes Eric, this command doesn't work on 2.6.24. Which timer are you susp=
ecting?


----- Original Message -----
=46rom: Eric Dumazet <eric.dumazet@gmail.com>
To: Kumar S <ps2kumar@yahoo.com>
Cc: netdev <netdev@vger.kernel.org>
Sent: Friday, September 9, 2011 3:08 PM
Subject: Re: Memory leak in ip_dst_cache

Le vendredi 09 septembre 2011 =E0 14:58 -0700, Kumar S a =E9crit :
> I agree, 3 MB is not a concern. But actually this is exceeding, we ar=
e
> seeing more than 1200000 objects in a span of 24 hours, which is clos=
e
> to 300 MB.

Hmm, please include netdev in your mails.

Then there is something else.

Maybe a timer bug preventing dst_gc_task() to make its duty.

>=A0 Other tasks require somewhere around 200 MB+. When it reaches this
> number, the board reboots. In lab we could simulate this. That is how
> I'm trying to understand the problem. I'm injecting around 10k routes=
,
> and waiting for them to ageout.
>=A0=20

I dont know, you could try disable IP route cache.

On recent (2.6.29+) kernels, thats very easy

# Disable Ip route cache (negative value in rebuild_count)
echo 3000000000 >/proc/sys/net/ipv4/rt_cache_rebuild_count

On an old kernel, you probably need to patch your kernel, or backport
commit 1080d709fb9d8cd43 (net: implement emergency route cache rebulds
when gc_elasticity is exceeded)
