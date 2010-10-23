From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Sat, 23 Oct 2010 17:11:09 +0200
Message-ID: <1287846669.2658.247.camel@edumazet-laptop>
References: <loom.20101012T185411-307@post.gmane.org>
	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>
	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>
	 <1287805487.2658.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:59044 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757041Ab0JWPLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Oct 2010 11:11:16 -0400
Received: by wwb34 with SMTP id 34so692688wwb.1
        for <netdev@vger.kernel.org>; Sat, 23 Oct 2010 08:11:15 -0700 (PDT)
In-Reply-To: <1287805487.2658.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 23 octobre 2010 =C3=A0 05:44 +0200, Eric Dumazet a =C3=A9crit=
 :
> Le vendredi 22 octobre 2010 =C3=A0 16:30 -0400, Joe Buehler a =C3=A9c=
rit :
> > Eric Dumazet wrote:
> >=20
> > > Could you provide a disassembly of function fib_rules_lookup ?
> >=20
> > Try looking in http://68.100.141.95:3000/linux-crash/.  There shoul=
d be
> > the source file I am using (not current release if you recall), the=
 .o,
> > the disassembly, and a -S compile that makes deducing the line numb=
ers a
> > little easier.
> >=20
>=20
> Hmm, I'll take a look sometime in the future, thanks

Did that... Hmm...

I am wondering if smp_rcu_assign_pointer() (or more precisely smp_wmb()=
)
is correctly implemented on octeon platform.

Try to add in fib_nl_newrule() right after the kzalloc bloc :

	rule =3D kzalloc(ops->rule_size, GFP_KERNEL);
	if (rule =3D=3D NULL) {
		err =3D -ENOMEM;
		goto errout;
	}
+       rule->list.next =3D LIST_POISON1;
+       rule->list.prev =3D LIST_POISON2;


So that we can actually see if the NULL dereference bug you hit becomes
a "LIST_POISON1" dereference bug...



