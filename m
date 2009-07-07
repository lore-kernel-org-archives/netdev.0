From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Tue, 07 Jul 2009 17:23:18 +0200
Message-ID: <4A536866.1050906@gmail.com>
References: <20090703090606.GA3902@elte.hu> <4A4DCD54.1080908@gmail.com> <20090703092438.GE3902@elte.hu> <20090703095659.GA4518@jolsa.lab.eng.brq.redhat.com> <20090703102530.GD32128@elte.hu> <20090703111848.GA10267@jolsa.lab.eng.brq.redhat.com> <20090707101816.GA6619@jolsa.lab.eng.brq.redhat.com> <20090707134601.GB6619@jolsa.lab.eng.brq.redhat.com> <20090707140135.GA5506@Krystal> <4A535EB9.2020406@gmail.com> <20090707145710.GB7124@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Olsa <jolsa@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50667 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643AbZGGPXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 11:23:49 -0400
In-Reply-To: <20090707145710.GB7124@Krystal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mathieu Desnoyers a =E9crit :

> But read_lock + smp_mb__after_lock + read_unlock is not well suited f=
or
> powerpc, arm, mips and probably others where there is an explicit mem=
ory
> barrier at the end of the read lock primitive.
>=20
> One thing that would be efficient for all architectures is to create =
a
> locking primitive that contains the smp_mb, e.g.:
>=20
> read_lock_smp_mb()
>=20
> which would act as a read_lock which does a full smp_mb after the loc=
k
> is taken.
>=20
> The naming may be a bit odd, better ideas are welcome.

I see your point now, thanks for your patience.

Jiri, I think your first patch can be applied (including the full smp_m=
b()),
 then we will optimize both for x86 and other arches, when all=20
arch maintainers have a chance to change
"read_lock();smp_mb()" to a faster "read_lock_mb()" or something :)

