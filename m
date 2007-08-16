From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 15:55:49 -0400
Message-ID: <46C4ABC5.0@redhat.com>
References: <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com> <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au> <18115.45316.702491.681906@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41452 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbXHPUDW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 16:03:22 -0400
In-Reply-To: <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> On Thu, 16 Aug 2007, Herbert Xu wrote:
>=20
>> We've been through that already.  If it's a busy-wait it
>> should use cpu_relax.=20
>=20
> I looked around a bit by using some command lines and ended up wonder=
ing=20
> if these are equal to busy-wait case (and should be fixed) or not:
>=20
> ./drivers/telephony/ixj.c
> 6674:   while (atomic_read(&j->DSPWrite) > 0)
> 6675-           atomic_dec(&j->DSPWrite);
>=20
> ...besides that, there are couple of more similar cases in the same f=
ile=20
> (with braces)...

atomic_dec() already has volatile behavior everywhere, so this is=20
semantically okay, but this code (and any like it) should be calling=20
cpu_relax() each iteration through the loop, unless there's a compellin=
g=20
reason not to.  I'll allow that for some hardware drivers (possibly thi=
s=20
one) such a compelling reason may exist, but hardware-independent core=20
subsystems probably have no excuse.

If the maintainer of this code doesn't see a compelling reason not to=20
add cpu_relax() in this loop, then it should be patched.

	-- Chris
