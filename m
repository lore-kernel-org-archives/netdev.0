From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Mon, 20 Sep 2010 14:40:42 +0200
Message-ID: <1284986442.3420.307.camel@edumazet-laptop>
References: <1283852248.2338.160.camel@edumazet-laptop>
	 <20100910.125449.235704956.davem@davemloft.net>
	 <20100911123140.GA1939@del.dom.local>
	 <20100919.171725.245378386.davem@davemloft.net>
	 <20100920072149.GA6353@ff.dom.local>
	 <1284973320.3420.49.camel@edumazet-laptop>
	 <20100920091425.GA8381@ff.dom.local>  <20100920121232.GA9931@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51576 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350Ab0ITMks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 08:40:48 -0400
Received: by wwj40 with SMTP id 40so1017wwj.1
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 05:40:46 -0700 (PDT)
In-Reply-To: <20100920121232.GA9931@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 septembre 2010 =C3=A0 12:12 +0000, Jarek Poplawski a =C3=A9=
crit :

> Hmm... I probably misread your reasoning. So, if no real reason,
> really, how about turning this NET_SKBUFF_DATA_USES_OFFSET on
> unconditionally in net-next, until somebody spots the difference?

Yes, but most developpers use 64bit kernels anyway, I suspect nobody
will ever notice :(

Here (with a typical config), here is the vmlinux size before and after
this patch :

$ size vmlinux.old
   text	   data	    bss	    dec	    hex	filename
6061748	 640208	7285056	13987012	 d56cc4	vmlinux.old

$ size vmlinux
   text	   data	    bss	    dec	    hex	filename
6070420	 640208	7285056	13995684	 d58ea4	vmlinux


Thats 8672 bytes of text increase.

(1330326 instructions instead of 1328472 -> 1854 more instructions)



