From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: filter: Convert the BPF VM to threaded code
Date: Fri, 29 Jul 2011 11:30:16 +0200
Message-ID: <1311931816.2843.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rui Ueyama <rui314@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51664 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820Ab1G2JaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 05:30:20 -0400
Received: by wwe5 with SMTP id 5so3342334wwe.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 02:30:19 -0700 (PDT)
In-Reply-To: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 juillet 2011 =C3=A0 01:10 -0700, Rui Ueyama a =C3=A9crit=
 :
> Convert the BPF VM to threaded code to improve performance.
>=20
> The BPF VM is basically a big for loop containing a switch statement.=
  That is
> slow because for each instruction it checks the for loop condition an=
d does the
> conditional branch of the switch statement.
>=20
> This patch eliminates the conditional branch, by replacing it with ju=
mp table
> using GCC's labels-as-values feature. The for loop condition check ca=
n also be
> removed, because the filter code always end with a RET instruction.
>=20

Well...


> +#define NEXT goto *jump_table[(++fentry)->code]
> +
> +	/* Dispatch the first instruction */
> +	goto *jump_table[fentry->code];

This is the killer, as this cannot be predicted by the cpu.

Do you have benchmark results to provide ?

We now have BPF JIT on x86_64 and powerpc, and possibly on MIPS and ARM
on a near future.



