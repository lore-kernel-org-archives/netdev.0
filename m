From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Mon, 21 Nov 2011 19:39:03 +0100
Message-ID: <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111121080554.GB1625@x4.trippels.de>
	 <20111121082445.GD1625@x4.trippels.de>
	 <1321866988.2552.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121131531.GA1679@x4.trippels.de>
	 <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121153621.GA1678@x4.trippels.de>
	 <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121161036.GA1679@x4.trippels.de>
	 <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121173556.GA1673@x4.trippels.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg
 <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>, Andrew Bresticker
	 <abrestic@google.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20111121173556.GA1673@x4.trippels.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le lundi 21 novembre 2011 =C3=A0 18:35 +0100, Markus Trippelsdorf a =C3=A9=
crit :

> New one:

...

I was just wondering if you were using CONFIG_CGROUPS=3Dy, and if yes, if
you could try to disable it.

css_get_next() looks very buggy, the read_lock()/read_unlock() protects
nothing at all, RCU rules are not respected.


commit c1e2ee2dc43657 (memcg: replace ss->id_lock with a rwlock) missed
the point of doing a true RCU conversion to get even better results, and
fact that previous code was buggy as well.

[ After rcu lookup, we must get a stable reference, then recheck the
key , or else we can manipulate something that was queued for deletion.]

An example of a correct RCU conversion was done in commit 8af088710d1
(posix-timers: RCU conversion)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
