From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] net: make ip_rt_acct a normal percpu var
Date: Thu, 20 Nov 2008 10:58:29 +1030
Message-ID: <200811201058.30017.rusty@rustcorp.com.au>
References: <200811172050.31308.rusty@rustcorp.com.au> <200811200943.21410.rusty@rustcorp.com.au> <4924A004.2050105@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48031 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751929AbYKTA2g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 19:28:36 -0500
In-Reply-To: <4924A004.2050105@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 20 November 2008 09:53:48 Eric Dumazet wrote:
> Rusty Russell a =E9crit :
> > On Thursday 20 November 2008 08:50:23 David Miller wrote:
> >> Do you really need this to forward some work you are doing?  If no=
t
> >> can we just let sleeping dogs lie on this one? :)
> >
> > Yes, I have patches to convert the dynamic percpu data to use the s=
ame
> > mechanism as static percpu data.  Unfortunately we don't have a mec=
hanism
> > for enlarging the percpu region (which is why this wasn't done earl=
ier),
> > so we use a heuristic to figure out how much extra percpu region to
> > allocate at boot.
> >
> > And 4k makes this one of the Big Pigs in dynamic per-cpu allocation=
s.
> >
> > (SNMP mibs are even worse, but that's a separate debate...)
> >
> > I can try to implement a bss-like DEFINE_PER_CPU_ZERO(), but it see=
ms
> > silly to talk about tight boot loader size restrictions for SMP ker=
nels.
>
> Then, if we really want to run 4096 cpus on a machine, we dont want t=
o
> allocate 16 MBytes of memory for these ip_rt_acct counters, or even m=
ore
> for SNMP mibs.
>
> Maybe its time to design a new mechanism, to avoid the basic "one var=
iable"
> shared by all cpus, and avoid the overkill "one separate variable for=
 each
> cpu", and loop 4096 times to do the sum of this variable...

Per-node vars; no doubt we'll get there.  It might be worth having YA p=
ercpu=20
counters implementation which does exactly this.  After the dynamic per=
cpu=20
changes and some local_* ops changes to allow use with dynamic percpu v=
ars, it=20
should be straightforward.

I don't think it's urgent: my concern is not with people who have 4096 =
cpus=20
(but I do care about people with 2 cpus and CONFIG_NR_CPUS=3D4096).

Cheers,
Rusty.
