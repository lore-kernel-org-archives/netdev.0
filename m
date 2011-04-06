From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: shutdown oops in xt_compat_calc_jump
Date: Wed, 06 Apr 2011 18:44:18 +0200
Message-ID: <1302108258.3209.117.camel@edumazet-laptop>
References: <20110404194856.GA3720@dannf.org> <4D9A23BC.4010505@trash.net>
	 <1301949477.3021.55.camel@edumazet-laptop>
	 <1301957293.3021.191.camel@edumazet-laptop>
	 <1301984679.3021.655.camel@edumazet-laptop>
	 <1301987879.3021.714.camel@edumazet-laptop>
	 <20110406162547.GA3064@dannf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: dann frazier <dannf@dannf.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110406162547.GA3064@dannf.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 06 avril 2011 =C3=A0 10:25 -0600, dann frazier a =C3=A9crit=
 :

> Thanks Eric. Unfortunately that didn't solve the problem I am seeing.
> I rebaselined (same kernel build as before), and found that I'm able
> to reproduce this 100% of the time by running only:
>=20
>   sudo ebtables -t filter --init-table
>=20
> The backtrace I received was this:


Oh yeah, I forgot to remove the WARN_ON_ONCE(1) at the end of
xt_compat_calc_jump()

I focused on restoring ebtables (for example ebtables -A INPUT ...)

Just ignore the warning for the time being ;)


# ebtables -A INPUT -p arp -s 00:01:02:03:04:05 -j ACCEPT
# ebtables -A INPUT -p arp -s 00:01:02:03:04:06 -j ACCEPT
# ebtables -L
Bridge table: filter

Bridge chain: INPUT, entries: 2, policy: ACCEPT
-p ARP -s 0:1:2:3:4:5 -j ACCEPT=20
-p ARP -s 0:1:2:3:4:6 -j ACCEPT=20

Bridge chain: FORWARD, entries: 0, policy: ACCEPT

Bridge chain: OUTPUT, entries: 0, policy: ACCEPT


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
