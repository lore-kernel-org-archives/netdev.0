From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: RFS configuration questions
Date: Fri, 03 Dec 2010 16:30:24 +0000
Message-ID: <1291393825.13384.4.camel@bwh-desktop>
References: <20101202211602.GA2775@BohrerMBP.rgmadvisors.com>
	 <1291326041.2854.2.camel@edumazet-laptop>
	 <20101203160035.GA2698@BohrerMBP.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	therbert@google.com
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:2564 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431Ab0LCQa2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 11:30:28 -0500
In-Reply-To: <20101203160035.GA2698@BohrerMBP.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-12-03 at 10:00 -0600, Shawn Bohrer wrote:
> On Thu, Dec 02, 2010 at 10:40:41PM +0100, Eric Dumazet wrote:
> > Le jeudi 02 d=C3=A9cembre 2010 =C3=A0 15:16 -0600, Shawn Bohrer a =C3=
=A9crit :
> > > I've been playing around with RPS/RFS on my multiqueue 10g Chelsi=
o NIC
> > > and I've got some questions about configuring RFS.
> > >=20
> > > I've enabled RPS with:
> > >=20
> > > for x in $(seq 0 7); do
> > >     echo FFFFFFFF,FFFFFFFF > /sys/class/net/vlan816/queues/rx-${x=
}/rps_cpus
> > > done
> > >=20
> > > This appears to work when I watch 'mpstat -P ALL 1' as I can see =
the
> > > softirq load is now getting distributed across all of the CPUs in=
stead
> > > of just the four (the card is a two port card and assigns four qu=
eues
> > > per port) original hw receive queues which I have bound to CPUs
> > > 0-3.
> > >=20
> > > To enable RFS I've run:
> > >=20
> > > echo 16384 > /proc/sys/net/core/rps_sock_flow_entries
> > >=20
> > > Is there any explanation of what this sysctl actually does?  Is t=
his
> > > the max number of sockets/flows that the kernel can steer?  Is th=
is a
> > > system wide max, a per interface max, or a per receive queue max?
> > >=20
> >=20
> > Yes, some doc is missing...
> >=20
> > Its a system wide and shared limit.
>=20
> So the sum of /sys/class/net/*/queues/rx-*/rps_flow_cnt should be les=
s
> than or equal to rps_sock_flow_entries?

No, that is not required.

> > > Next I ran:
> > >=20
> > > for x in $(seq 0 7); do
> > >     echo 16384 > /sys/class/net/vlan816/queues/rx-${x}/rps_flow_c=
nt
> > > done
> > >=20
> > > Is this correct?  Is these the max number of sockets/flows that c=
an be
> > > steered per receive queue?  Does the sum of these values need to =
add
> > > up to rps_sock_flow_entries (I also tried 2048)? Is this all that=
 is
> > > needed to enable RFS?
> > >=20
> >=20
> > Yes thats all.
>=20
> Same as above... I should be using 2048 if I have 8 queues and have
> set rps_sock_flow_entries to 16384?  Out of curiosity what happens
> when you open more sockets than you have rps_flow_cnt?
[...]

There will be a hash collision - multiple flows will hash to the same
value and must therefore be handled on the same processor.  (In fact
this is likely to happen long before you fill the table completely.)

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

