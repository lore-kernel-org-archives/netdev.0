From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Sat, 23 Oct 2010 05:44:47 +0200
Message-ID: <1287805487.2658.5.camel@edumazet-laptop>
References: <loom.20101012T185411-307@post.gmane.org>
	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>
	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61579 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756319Ab0JWDo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 23:44:58 -0400
Received: by wyf28 with SMTP id 28so1564159wyf.19
        for <netdev@vger.kernel.org>; Fri, 22 Oct 2010 20:44:57 -0700 (PDT)
In-Reply-To: <4CC1F47C.9020104@cox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 22 octobre 2010 =C3=A0 16:30 -0400, Joe Buehler a =C3=A9cri=
t :
> Eric Dumazet wrote:
>=20
> > Could you provide a disassembly of function fib_rules_lookup ?
>=20
> Try looking in http://68.100.141.95:3000/linux-crash/.  There should =
be
> the source file I am using (not current release if you recall), the .=
o,
> the disassembly, and a -S compile that makes deducing the line number=
s a
> little easier.
>=20

Hmm, I'll take a look sometime in the future, thanks

> I have tried adding a recursive spinlock as a quick fix without much
> success.  It looks like the code in net/core/fib_rules.c results in s=
ome
> rather complex code paths through the kernel involving softirq handle=
rs.
>  I get lockups though I took steps to make sure local interrupts were
> off and preemption disabled when taking the spinlock.
>=20
> I do not know the RCU API or the network code at all but some of the
> code in fib_rules.c does not look right prima facie.  For example,
> dump_rules does not seem to bother about RCU when traversing rules_li=
st.
>  Its caller, fib_nl_dumprule does, but only for one of two calls.  Th=
e
> fib_nl_newrule and fib_nl_delrule functions traverse rules_list witho=
ut
> any obvious RCU precautions.

There is no obligation RCU shall be used in a slow path algorithm.

This slow path uses regular locking to prevent another process to chang=
e
the things while we read them, thats it.

Patrick made a change in the past so that RTNL is locked on dump
operations, so no dump_rules() is in fact protected by RTNL, it doesnt
need to take care of 'RCU'.

Thanks



