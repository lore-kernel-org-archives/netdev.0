From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] lib: cpu_rmap: CPU affinity reverse-mapping
Date: Tue, 04 Jan 2011 21:23:36 +0000
Message-ID: <1294176216.3636.38.camel@bwh-desktop>
References: <1294169842.3636.31.camel@bwh-desktop>
	 <1294169967.3636.34.camel@bwh-desktop>
	 <1294175823.3420.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294175823.3420.7.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-01-04 at 22:17 +0100, Eric Dumazet wrote:
> Le mardi 04 janvier 2011 =C3=A0 19:39 +0000, Ben Hutchings a =C3=A9cr=
it :
> > When initiating I/O on a multiqueue and multi-IRQ device, we may wa=
nt
> > to select a queue for which the response will be handled on the sam=
e
> > or a nearby CPU.  This requires a reverse-map of IRQ affinity.  Add
> > library functions to support a generic reverse-mapping from CPUs to
> > objects with affinity and the specific case where the objects are
> > IRQs.
[...]
> > +/**
> > + * struct cpu_rmap - CPU affinity reverse-map
> > + * @near: For each CPU, the index and distance to the nearest obje=
ct,
> > + *      based on affinity masks
> > + * @size: Number of objects to be reverse-mapped
> > + * @used: Number of objects added
> > + * @obj: Array of object pointers
> > + */
> > +struct cpu_rmap {
> > +	struct {
> > +		u16     index;
> > +		u16     dist;
> > +	} near[NR_CPUS];
>=20
> This [NR_CPUS] is highly suspect.
>=20
> Are you sure you cant use a per_cpu allocation here ?

I think that would be a waste of space in shared caches, as this is
read-mostly.

> > +	u16		size, used;
> > +	void		*obj[0];
> > +};
> > +#define CPU_RMAP_DIST_INF 0xffff
> > +
>=20
>=20
> > +
> > +/**
> > + * alloc_cpu_rmap - allocate CPU affinity reverse-map
> > + * @size: Number of objects to be mapped
> > + * @flags: Allocation flags e.g. %GFP_KERNEL
> > + */
>=20
> I really doubt you need other than GFP_KERNEL. (Especially if you swi=
tch
> to per_cpu alloc ;) )
[...]

I agree, but this is consistent with ~all other allocation functions.

Ben.


--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
