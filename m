From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Fri, 03 Dec 2010 07:32:33 +0100
Message-ID: <1291357953.2854.46.camel@edumazet-laptop>
References: <AANLkTin6d=t6U28A-r=FznqE+5QuGXwg1tStOw-JXabg@mail.gmail.com>
	 <1291192967.2856.492.camel@edumazet-laptop>
	 <18eaf7d286236427b1632b9af62be513@localhost>
	 <20101201.101809.71122121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hagen@jauu.net, xiaosuo@gmail.com, wirelesser@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:58373 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717Ab0LCGck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 01:32:40 -0500
Received: by wwe15 with SMTP id 15so630847wwe.1
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 22:32:39 -0800 (PST)
In-Reply-To: <20101201.101809.71122121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 10:18 -0800, David Miller a =C3=
=A9crit :

> However, I think it's still valuable to write a few JIT compilers for
> the existing BPF stuff.  I considered working on a sparc64 JIT just t=
o
> see what it would look like.
>=20
> If people work on the BPF optimizer and BPF JITs in parallel, we'll h=
ave
> both ready at the same time.  win++

I began work on implementing a BPF JIT for x86_64

My plan is to use external helpers to load skb data/metadata, to keep
BPF program very short and have no dependencies against struct layouts.

These helpers would be the three load_word, load_half, load_byte.

In case the bits are in skb head, these helpers should be fast.

=46or practical reasons, they would be in ASM for their fast path, and =
C
for the slow path. They are ASM because they are able to perform the
shortcut (in case of error, doing the stack unwind to perform the
"return 0;") so that we dont have to test their return from the JIT
program.



