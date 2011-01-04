From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] lib: cpu_rmap: CPU affinity reverse-mapping
Date: Tue, 04 Jan 2011 22:45:48 +0100
Message-ID: <1294177548.3420.11.camel@edumazet-laptop>
References: <1294169842.3636.31.camel@bwh-desktop>
	 <1294169967.3636.34.camel@bwh-desktop>
	 <1294175823.3420.7.camel@edumazet-laptop>
	 <1294176216.3636.38.camel@bwh-desktop>
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
In-Reply-To: <1294176216.3636.38.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 04 janvier 2011 =C3=A0 21:23 +0000, Ben Hutchings a =C3=A9crit=
 :
> On Tue, 2011-01-04 at 22:17 +0100, Eric Dumazet wrote:
> > Le mardi 04 janvier 2011 =C3=A0 19:39 +0000, Ben Hutchings a =C3=A9=
crit :
> > > When initiating I/O on a multiqueue and multi-IRQ device, we may =
want
> > > to select a queue for which the response will be handled on the s=
ame
> > > or a nearby CPU.  This requires a reverse-map of IRQ affinity.  A=
dd
> > > library functions to support a generic reverse-mapping from CPUs =
to
> > > objects with affinity and the specific case where the objects are
> > > IRQs.
> [...]
> > > +/**
> > > + * struct cpu_rmap - CPU affinity reverse-map
> > > + * @near: For each CPU, the index and distance to the nearest ob=
ject,
> > > + *      based on affinity masks
> > > + * @size: Number of objects to be reverse-mapped
> > > + * @used: Number of objects added
> > > + * @obj: Array of object pointers
> > > + */
> > > +struct cpu_rmap {
> > > +	struct {
> > > +		u16     index;
> > > +		u16     dist;
> > > +	} near[NR_CPUS];
> >=20
> > This [NR_CPUS] is highly suspect.
> >=20
> > Are you sure you cant use a per_cpu allocation here ?
>=20
> I think that would be a waste of space in shared caches, as this is
> read-mostly.

This is slow path, unless I dont understood the intent.

Cache lines dont matter. I was not concerned about speed but memory
needs.

NR_CPUS can be 4096 on some distros, that means a 32Kbyte allocation.

Really, you'll have to have very strong arguments to introduce an
[NR_CPUS] array in the kernel today.
