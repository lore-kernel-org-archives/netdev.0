From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] lib: cpu_rmap: CPU affinity reverse-mapping
Date: Tue, 04 Jan 2011 23:19:02 +0100
Message-ID: <1294179542.3420.13.camel@edumazet-laptop>
References: <1294169842.3636.31.camel@bwh-desktop>
	 <1294169967.3636.34.camel@bwh-desktop>
	 <1294175823.3420.7.camel@edumazet-laptop>
	 <1294176216.3636.38.camel@bwh-desktop>
	 <1294177548.3420.11.camel@edumazet-laptop>
	 <1294178690.3636.49.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294178690.3636.49.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 04 janvier 2011 =C3=A0 22:04 +0000, Ben Hutchings a =C3=A9crit=
 :

> get_rps_cpu() will need to read from an arbitrary entry in cpu_rmap (=
not
> the current CPU's entry) for each new flow and for each flow that wen=
t
> idle for a while.  That's not fast path but it is part of the data pa=
th,
> not the control path.
>=20

Hmm, I call this fast path :(

> > Cache lines dont matter. I was not concerned about speed but memory
> > needs.
> >=20
> > NR_CPUS can be 4096 on some distros, that means a 32Kbyte allocatio=
n.
> >=20
> > Really, you'll have to have very strong arguments to introduce an
> > [NR_CPUS] array in the kernel today.
>=20
> I could replace this with a pointer to an array of size
> num_possible_cpus().  But I think per_cpu is wrong here.

Yes, an dynamic array is acceptable

You probably mean nr_cpu_ids=20
