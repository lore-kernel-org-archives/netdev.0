From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: md5: rcu conversion
Date: Tue, 31 Jan 2012 16:38:37 +0100
Message-ID: <1328024317.2297.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1327975638-16530-1-git-send-email-shawn.lu@ericsson.com>
	 <CAL4WiipdO5+1Fi_ig5hB25d2LJvc+cjzyAbo8mxx3e4EiRx9YA@mail.gmail.com>
	 <62162DF05402B341B3DB59932A1FA992B5B5B929BD@EUSAACMS0702.eamcs.ericsson.se>
	 <1328000712.2422.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328016828.2297.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328023113.2297.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35714 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753575Ab2AaPil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 10:38:41 -0500
Received: by bkcjm19 with SMTP id jm19so70685bkc.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 07:38:40 -0800 (PST)
In-Reply-To: <1328023113.2297.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 31 janvier 2012 =C3=A0 16:18 +0100, Eric Dumazet a =C3=A9crit =
:
> In order to be able to support proper RST messages for TCP MD5 flows,=
 we
> need to allow access to MD5 keys without locking listener socket.
>=20
> This conversion is a nice cleanup, and shrinks size of timewait socke=
ts
> by 80 bytes.
>=20
> IPv6 code reuses generic code found in IPv4 instead of duplicating it=
=2E
>=20
> Control path uses GFP_KERNEL allocations instead of GFP_ATOMIC.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Shawn Lu <shawn.lu@ericsson.com>

By the way, we probably need to add a limit on the number of keys a
socket can store. It seems previous code relied on kmalloc(big_array)
limits  (~4MB on x86) only.

sock_kmalloc() might be the right thing to use instead of kmalloc()
