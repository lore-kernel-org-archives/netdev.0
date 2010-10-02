From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2.6.35.7] net: Fix the condition passed to
 sk_wait_event()
Date: Sat, 02 Oct 2010 10:34:01 +0200
Message-ID: <1286008441.2582.851.camel@edumazet-laptop>
References: <667106.4951.qm@web53706.mail.re2.yahoo.com>
	 <1286008051.2582.846.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Nagendra Tomar <tomer_iisc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61307 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507Ab0JBIeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Oct 2010 04:34:08 -0400
In-Reply-To: <1286008051.2582.846.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 02 octobre 2010 =C3=A0 10:27 +0200, Eric Dumazet a =C3=A9crit=
 :

> Just wondering why you remove the test on sk->err ?
>=20
> We want to break the loop If sk->sk_err is set, or state is ESTABLISH=
ED
> or CLOSE_WAIT.

Hmm, reading the code again, I can see sk_err is tested in the loop, so
your code is better (sk_stream_wait_connect() returns an error after
your patch, instead of returning 0)

Could you please split your patch in two patches ?

The sk_stream_wait_connect() problems comes from commit
c1cbe4b7ad0bc4b1d9 ([NET]: Avoid atomic xchg() for non-error case)




