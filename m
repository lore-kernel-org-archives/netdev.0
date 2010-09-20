From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] qlcnic: dont assume NET_IP_ALIGN is 2
Date: Mon, 20 Sep 2010 14:18:38 +0200
Message-ID: <1284985118.3420.270.camel@edumazet-laptop>
References: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
	 <1284700483-16397-2-git-send-email-amit.salecha@qlogic.com>
	 <1284717448.3391.75.camel@edumazet-laptop>
	 <99737F4847ED0A48AECC9F4A1974A4B80F86F8018D@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	David Miller <davem@davemloft.net>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41941 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054Ab0ITMSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 08:18:43 -0400
Received: by wwj40 with SMTP id 40so40596wwj.1
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 05:18:42 -0700 (PDT)
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80F86F8018D@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 septembre 2010 =C3=A0 06:16 -0500, Amit Salecha a =C3=A9cri=
t :

> This can be cleaned up.=20
> Though I have one doubt. We are allocating larger packets than the ac=
tual data used.
> Doesn't it will break accounting ?

truesize accounts for the real size of buffers, not the used part in
them.

IMHO, a driver not dealing with fragments should not touch skb->truesiz=
e

# grep truesize drivers/net/tg3.c
<nothing>

If a driver deals with fragments, it probably should use "+=3D" operato=
r
only, not hardcoding sizeof(struct sk_buff) thing that only core networ=
k
has to deal with.

$ find drivers/net/bnx2x|xargs grep truesize
drivers/net/bnx2x/bnx2x_cmn.c:		skb->truesize +=3D frag_len;

Almost all drivers are fine, they are some of them that should be
changed.



