From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/9] Fix leaking of kernel heap addresses in net/
Date: Sun, 07 Nov 2010 18:03:36 +0100
Message-ID: <1289149416.2478.143.camel@edumazet-laptop>
References: <1289147492.3090.137.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com,
	netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46242 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985Ab0KGRDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 12:03:42 -0500
Received: by fxm16 with SMTP id 16so3517470fxm.19
        for <netdev@vger.kernel.org>; Sun, 07 Nov 2010 09:03:41 -0800 (PST)
In-Reply-To: <1289147492.3090.137.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 07 novembre 2010 =C3=A0 11:31 -0500, Dan Rosenberg a =C3=A9=
crit :
> This patch series resolves the leakage of kernel heap addresses to
> userspace via network protocol /proc interfaces and public error
> messages.  Revealing this information is a bad idea from a security
> perspective for a number of reasons, the most obvious of which is it
> provides unprivileged users a mechanism by which to create a structur=
e
> in the kernel heap containing function pointers, obtain the address o=
f
> that structure, and overwrite those function pointers by leveraging
> other vulnerabilities.  It is my hope that by eliminating this
> information leakage, in conjunction with making statically-declared
> function pointer tables read-only (to be done in a separate patch
> series), we can at least add a small hurdle for the exploitation of a
> subset of kernel vulnerabilities.
>=20
> To maintain compatibility with userspace programs relying on
> consistent /proc output, the output descriptions and number of fields
> are not changed.  When a unique identifier for the socket is desired,
> the socket address has been replaced with the socket inode number.  W=
hen
> the inode number is already present in the output, the address has be=
en
> replaced with a 0.  In these cases, the format specifier has been
> changed to %d, because a %p output of 0 from kernel space is written =
as
> "(null)", while userspace %p can only parse "(nil)".
>=20

NACK

Thats a pretty stupid patch series, sorry.

You are basically ruining a lot of debugging facilities we use every da=
y
to find and fix _real_ bugs. The bugs that happen to crash machines of
our customers.

If you want to avoid a user reading kernel syslog, why dont you fix the
problem for non root users able to "dmesg" ? I personally dont care.

I am a root user on my machine, I _want_ to have some pretty basic
informations so that I can work on it, and I believe my work is useful.

There are pretty easy ways to not disclose "information", but your way
of using '0' for all values is the dumbest idea one could ever had.

A single XOR with a "root only visible, random value chosen at boot"
would be OK. At least we could continue our work, with litle burden.


