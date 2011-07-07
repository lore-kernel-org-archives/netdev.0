From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38032] New: default values of
 /proc/sys/net/ipv4/udp_mem does not consider huge page allocation
Date: Thu, 07 Jul 2011 05:59:33 +0200
Message-ID: <1310011173.2481.20.camel@edumazet-laptop>
References: <bug-38032-10286@https.bugzilla.kernel.org/>
	 <20110706160318.2c604ae9.akpm@linux-foundation.org>
	 <6.2.5.6.2.20110706212254.05bff4c8@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org, Rafael Aquini
 <aquini@linux.com>
To: starlight@binnacle.cx
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <6.2.5.6.2.20110706212254.05bff4c8@binnacle.cx>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le mercredi 06 juillet 2011 =C3=A0 21:31 -0400, starlight@binnacle.cx a
=C3=A9crit :
> For anyone who may not have read the bugzilla, a
> possibly larger concern subsequently discovered is
> that actual kernel memory consumption is double the
> total of the values reported by 'netstat -nau', at
> least when mostly small packets are received and
> a RHEL 5 kernel is in use.  The tunable enforces based
> on the 'netstat' value rather than the actual value
> in the RH kernel.  Maybe not an issue in the
> mainline, but it took a few additional system
> hangs in the lab before we figured this out
> and divided the 'udm_mem' maximum value in half.
>=20

Several problems here

1) Hugepages can be setup after system boot, and udp_mem/tcp_mem not
updated accordingly.

2) Using SLUB debug or kmemcheck for instance adds lot of overhead, that
we dont take into account (it would probably be expensive to do so).
Even ksize(ptr) is not able to really report memory usage of an object.

3) What happens if both tcp and udp sockets are in use on the system,
shouls we half both udp_mem and tcp_mem just in case ?

Now if you also use SCTP sockets, UDP-Lite sockets, lot of file
mappings, huge pages, conntracking, posix timers (currently not
limited), threads, ..., what happens ? Should we then set udp_mem to 1%
of current limit just in case ?

What about fixing the real problem instead ?

When you say the system freezes, is it in the UDP stack, or elsewhere ?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
