From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux Route Cache performance tests
Date: Sun, 06 Nov 2011 22:26:28 +0100
Message-ID: <1320614788.6506.38.camel@edumazet-laptop>
References: <4EB6AE62.5050803@itcare.pl>
	   <1320600597.6506.7.camel@edumazet-laptop> <4EB6D1D8.8040604@itcare.pl>
	  <1320605326.6506.27.camel@edumazet-laptop> <4EB6DE06.7050009@itcare.pl>
	 <1320608290.6506.33.camel@edumazet-laptop> <4EB6ED2E.1070106@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45774 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132Ab1KFV0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2011 16:26:33 -0500
Received: by wyh15 with SMTP id 15so3911208wyh.19
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2011 13:26:32 -0800 (PST)
In-Reply-To: <4EB6ED2E.1070106@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 06 novembre 2011 =C3=A0 21:25 +0100, Pawe=C5=82 Staszewski =
a =C3=A9crit :
> Yes with this is a little problem i think with kernel 3.1 because
> dmesg | egrep  '(rhash)|(route)'
> [    0.000000] Command line: root=3D/dev/md2 rhash_entries=3D2097152
> [    0.000000] Kernel command line: root=3D/dev/md2 rhash_entries=3D2=
097152
> [    4.697294] IP route cache hash table entries: 524288 (order: 10,=20
> 4194304 bytes)
>=20
>=20

Dont tell me you _still_ use a 32bit kernel ?

If so, you need to tweak alloc_large_system_hash() to use vmalloc,
because you hit MAX_ORDER (10) page allocations.

But considering LOWMEM is about 700 Mbytes, you wont be able to create =
a
lot of route cache entries.

Come on, do us a favor, and enter new era of computing.
