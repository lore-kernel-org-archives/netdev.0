From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Sat, 07 Jan 2006 09:30:27 +0100
Message-ID: <43BF7C23.5070805@cosmosbay.com>
References: <43BEA693.5010509@cosmosbay.com>	<20060106202626.GA5677@us.ibm.com>	<200601062157.42470.ak@suse.de> <20060106.161721.124249301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ak@suse.de, paulmck@us.ibm.com, alan@lxorguk.ukuu.org.uk,
	torvalds@osdl.org, linux-kernel@vger.kernel.org,
	dipankar@in.ibm.com, manfred@colorfullife.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030358AbWAGIad@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060106.161721.124249301.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller a =E9crit :
>=20
> Eric, how important do you honestly think the per-hashchain spinlocks
> are?  That's the big barrier from making rt_secret_rebuild() a simple
> rehash instead of flushing the whole table as it does now.
>=20

No problem for me in going to a single spinlock.
I did the hashed spinlock patch in order to reduce the size of the rout=
e hash=20
table and not hurting big NUMA machines. If you think a single spinlock=
 is OK,=20
that's even better !

> The lock is only grabbed for updates, and the access to these locks i=
s
> random and as such probably non-local when taken anyways.  Back befor=
e
> we used RCU for reads, this array-of-spinlock thing made a lot more
> sense.
>=20
> I mean something like this patch:
>=20

> +static DEFINE_SPINLOCK(rt_hash_lock);


Just one point : This should be cache_line aligned, and use one full ca=
che=20
line to avoid false sharing at least. (If a cpu takes the lock, no need=
 to=20
invalidate *rt_hash_table for all other cpus)

Eric
