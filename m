From: Christian Tschudin <Christian.Tschudin@unibas.ch>
Subject: Re: PROBLEM: nd_tbl not a public symbol in net/ipv6/ndisc.c
Date: Mon, 31 Jan 2005 10:16:29 +0100 (MET)
Message-ID: <Pine.OSF.4.58.0501310922130.2054@igor.urz.unibas.ch>
References: <Pine.OSF.4.58.0501310903220.211@igor.urz.unibas.ch>
 <20050131.172022.93845025.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20050131.172022.93845025.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 31 Jan 2005, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:

> In article <Pine.OSF.4.58.0501310903220.211@igor.urz.unibas.ch> (at Mon=
, 31 Jan 2005 09:04:34 +0100 (MET)), Christian Tschudin <Christian.Tschud=
in@unibas.ch> says:
>
> > Our LUNAR project (underlay for wireless multihop networks)
> > stumbled over the same problem that at least two other projects
> > (infiniband, and mipv6) also experienced many months ago:
> >
> >   The neighbor table 'nd_tbl' in net/ipv6/ndisc.c
> >   is not accessible from other modules.
> :
> > +EXPORT_SYMBOL(nd_tbl);
>
> I disagree.
> Basically, ndisc.c is the only user of that structure and
> I cannot find why you really need this symbol.

We have implemented an underlay network layer protocol.
This means that we present to the IP stack a subnet illusion
while doing wireless multihop forwarding underneath.
To this end we need to set and unset entries in the neighbor
table, because we are actively managing neighbors.

Now, if you know a technique how to invoke

  neigh_lookup(struct neigh_table *tbl, ...)
or
  neigh_lookup_errno(struct neigh_table *tbl, ...)

without having the reference to nd_tbl (i.e., getting at this
value by some indirect means), we would be happy use it.
Is there a way? Otherwise, we need a public nd_tbl symbol.

best, christian

---
Christian Tschudin, University of Basel       http://cn.cs.unibas.ch/
Computer Science Dept, Bernoullistr. 16, CH - 4056 Basel, Switzerland
