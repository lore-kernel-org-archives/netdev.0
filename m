From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: 2.6.21 -> 2.6.22 & 2.6.23-rc8 performance regression
Date: Mon, 01 Oct 2007 10:35:02 +0200
Message-ID: <4700B136.8050109@cosmosbay.com>
References: <200709301425.37564.nickpiggin@yahoo.com.au> <20070930223503.M8966@nuclearcat.com> <47008CB0.7010808@cosmosbay.com> <20071001.001259.28812610.davem@davemloft.net> <20071001080339.M21850@nuclearcat.com> <4700ADB7.7050102@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys <nuclearcat@nuclearcat.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([80.12.242.50]:19040 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751713AbXJAIfI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 04:35:08 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2303.orange.fr (SMTP Server) with ESMTP id E40501C0009E
	for <netdev@vger.kernel.org>; Mon,  1 Oct 2007 10:35:06 +0200 (CEST)
In-Reply-To: <4700ADB7.7050102@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =C3=A9crit :
> Denys a =C3=A9crit :
>> Well, i can play a bit more on "live" servers. I have now hot-swap=20
>> server with
>> full gentoo,  where i can rebuild any kernel you want, with any=20
>> applied patch.
>> But it looks more like not overhead, load becoming high too "spiky",=
=20
>> and it is
>> not just permantenly higher. Also it is not normal that all system=20
>> becoming
>> unresposive (for example ping 127.0.0.1 becoming 300ms for period,=20
>> when usage
>> softirq jumps to 100%).
>>
>>  =20
> Could you try a pristine 2.6.22.9 and some patch in=20
> secure_tcp_sequence_number() like :
>
> --- drivers/char/random.c.orig 2007-10-01 10:18:42.000000000 +0200
> +++ drivers/char/random.c 2007-10-01 10:19:58.000000000 +0200
> @@ -1554,7 +1554,7 @@
> * That's funny, Linux has one built in! Use it!
> * (Networks are faster now - should this be increased?)
> */
> - seq +=3D ktime_get_real().tv64;
> + seq +=3D ktime_get_real().tv64 / 1000;
> #if 0
> printk("init_seq(%lx, %lx, %d, %d) =3D %d\n",
> saddr, daddr, sport, dport, seq);
On 32 bits machine, replace the divide by a shift  to avoid a linker=20
error (undefined reference to `__divdi3'): =20

seq +=3D ktime_get_real().tv64 >> 10;





