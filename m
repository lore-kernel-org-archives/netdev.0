From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question regarding expected behavior of two udp sockets with
 SO_REUSEADDR set
Date: Sat, 20 Nov 2010 16:44:47 +0100
Message-ID: <1290267887.2756.75.camel@edumazet-laptop>
References: <20101120004847.GA2590@hmsreliant.think-freely.org>
	 <1290226015.2756.14.camel@edumazet-laptop>
	 <20101120150441.GA17907@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43140 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210Ab0KTPoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Nov 2010 10:44:54 -0500
Received: by wwa36 with SMTP id 36so5743846wwa.1
        for <netdev@vger.kernel.org>; Sat, 20 Nov 2010 07:44:53 -0800 (PST)
In-Reply-To: <20101120150441.GA17907@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 20 novembre 2010 =C3=A0 10:04 -0500, Neil Horman a =C3=A9crit=
 :

> Agreed.  My thought was to add logic to udp_lib_lport_inuse such that=
, if
> sk_reuse is set on both sockets, and the input snum is 0 (indicating =
autobind)
> we should not allow binding sk to inet_sk(sk2)->num.  Thoughts?

I dont know, problem is this could be possible right now if sk2 is boun=
d
on 127.0.0.2 address. Adding this test would reduce possible space.

Autobind is tricky, it chooses a port while address is part of the
problem.

Some loopback scalability problems could be solved if full range of
127.0.0.0/8 addresses were used, avoiding the dst refcount false
sharing :)



