From: Christian Tschudin <Christian.Tschudin@unibas.ch>
Subject: Re: PROBLEM: nd_tbl not a public symbol in net/ipv6/ndisc.c
Date: Thu, 24 Feb 2005 09:47:39 +0100 (MET)
Message-ID: <Pine.OSF.4.58.0502240942570.11226@igor.urz.unibas.ch>
References: <Pine.OSF.4.58.0501310903220.211@igor.urz.unibas.ch>
 <20050131.172022.93845025.yoshfuji@linux-ipv6.org>
 <Pine.OSF.4.58.0501310922130.2054@igor.urz.unibas.ch>
 <20050131.190157.42878368.yoshfuji@linux-ipv6.org>
 <Pine.OSF.4.58.0501311111380.2054@igor.urz.unibas.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <Pine.OSF.4.58.0501311111380.2054@igor.urz.unibas.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

three weeks ago we had a message exchang on nd_tbl not
being a public symbol; I had sent you some code for showing
the usage.

What do you think now?

best, christian.

---
Christian Tschudin, University of Basel       http://cn.cs.unibas.ch/
Computer Science Dept, Bernoullistr. 16, CH - 4056 Basel, Switzerland

On Mon, 31 Jan 2005, Christian Tschudin wrote:

> On Mon, 31 Jan 2005, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:
>
> > Ok, but basically, we do not export it unless it is really used.
> > We may do if it is necessary when you merge it.
> >
> > BTW, for your purpose, we may export
> >  ndisc_lookup()
> > or something instead of nd_tbl itself.
> >
> > Anyway, I'd like to know the usage (code).
>
> Your new ndisc_lookup() would need to distinguish the IP address types
> (relating to different tables).
>
> Here is roughly what we do:
>
> ---
> int netbox_neigh_map(struct net_device *dev,
> 		     struct lunartarget_s *host,
> 		     char *eth)
> {
> 	struct neighbour *neigh =3D 0;
>
> 	if (TARGET_IS_IPV4(host))
> 		neigh =3D neigh_lookup_errno(&arp_tbl, (struct in_addr*)&(host->addr.=
ipv4), dev);
> 	else if (TARGET_IS_IPV6(host))
> 		neigh =3D neigh_lookup_errno(&nd_tbl, &host->addr.ipv6, dev);
>
>         if (!IS_ERR(neigh)) {
> 		neigh->parms->delay_probe_time =3D 0;
>                 NEIGH_UPDATE(neigh, eth, NUD_REACHABLE, 1, 0);
>                 neigh_release(neigh);
>         }
>
> 	return 0;
> }
> ---
>
> Our other function netbox_neigh_unmap() is basically the same,
> with the flag NUD_REACHABLE replaced by NUD_NONE.
>
> best, christian
>
> PS: full code (use guest/guest for username/password) at
>     https://subversion.cs.unibas.ch/repos/lunar/trunk/lnx/knetbox.c
>
> >
> > --yoshfuji
> >
>
