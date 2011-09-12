From: Kumar S <ps2kumar@yahoo.com>
Subject: Re: Memory leak in ip_dst_cache
Date: Sun, 11 Sep 2011 20:38:30 -0700 (PDT)
Message-ID: <1315798710.96027.YahooMailNeo@web113913.mail.gq1.yahoo.com>
References: <1315544674.20226.YahooMailNeo@web113902.mail.gq1.yahoo.com> <1315546223.5410.23.camel@edumazet-laptop> <1315593553.98279.YahooMailNeo@web113904.mail.gq1.yahoo.com> <1315596786.2606.3.camel@edumazet-laptop> <1315601283.91185.YahooMailNeo@web113908.mail.gq1.yahoo.com> <1315604820.2606.13.camel@edumazet-laptop> <1315605497.25052.YahooMailNeo@web113916.mail.gq1.yahoo.com> <1315606125.2606.19.camel@edumazet-laptop> <1315608825.98066.YahooMailNeo@web113914.mail.gq1.yahoo.com> <20110910130416.GA2005@neilslaptop.think-freely.org>
Reply-To: Kumar S <ps2kumar@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm28-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.234]:45711 "HELO
	nm28-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753091Ab1ILDjb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Sep 2011 23:39:31 -0400
In-Reply-To: <20110910130416.GA2005@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Neil. I did try with prink(). I do see entries getting aged out,=
 but they are not getting deallocated. This seems to be happening becau=
se of "ref_cnt". When the route entries are added the ref_cnt is set to=
 1. Looks this is causing trouble clearing the entries completely. If I=
 set the ref_cnt to 0, I can see it working. Now I'm trying to understa=
nd whether this is right. Please let me know if you have any thoughts o=
n it.


----- Original Message -----
=46rom: Neil Horman <nhorman@tuxdriver.com>
To: Kumar S <ps2kumar@yahoo.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>; netdev <netdev@vger.kernel.o=
rg>
Sent: Saturday, September 10, 2011 6:04 AM
Subject: Re: Memory leak in ip_dst_cache

On Fri, Sep 09, 2011 at 03:53:45PM -0700, Kumar S wrote:
> Yes Eric, this command doesn't work on 2.6.24. Which timer are you su=
specting?
>=20
He means that the timer that starts the the workqueue which calls dst_g=
c_task is
either delayed indefinately, or otherwise not run, which means that the=
 route
cache will never be scanned for old entries.=A0 The implication being t=
hat, while
the dst entries aren't leaked per-se, but never expired, so they just s=
it
around.=A0 You can check this by instrumenting gc_dst_task with a print=
k or two
and watch to see if it ever pops up.

If you only have 512Mb of ram and want to really restrict you're cache =
size, you
should definately consider backporting the route cache rebuild patch to=
 disable
the route cache usage entirely.=A0 It shouldn't be too hard to do.
Neil

>=20
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at=A0 http://vger.kernel.org/majordomo-info.html
