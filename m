From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug] skb truesize does not update properly in many place
Date: Fri, 14 Oct 2011 07:48:33 +0200
Message-ID: <1318571313.2533.77.camel@edumazet-laptop>
References: <1318570381-4731-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61243 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932566Ab1JNFsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 01:48:42 -0400
Received: by wwf22 with SMTP id 22so2901325wwf.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 22:48:41 -0700 (PDT)
In-Reply-To: <1318570381-4731-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 octobre 2011 =C3=A0 13:33 +0800, roy.qing.li@gmail.com a
=C3=A9crit :
> Hi Eric Dumazet:
>=20
> I see you are correcting the wrong skb truesize, I found the
> same problem exists in many forms and many places, like:
>=20
> After calling skb_fill_page_desc(), what should be updated=20
> to truesize.
>=20
> pskb_expand_head(), __pskb_pull_tail()... do not update the
> truesize.

All this is scheduled, but any help is appreciated.

I gave the general idea and patched some drivers, I hope other dev will
follow me in this work.

I am now focusing in the TCP pruning effect, that we can see with WIFI
drivers (and also with drivers using a full PAGE to store a 1500 byte
tcp frame), when a single packet loss is happening on a session with
large RTT.

All this truesize saga started because I was shocked by following
"netstat -s" extract on my laptop after few minutes of Internet stuff.

    848 packets collapsed in receive queue due to low socket buffer
