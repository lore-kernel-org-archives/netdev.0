From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/af_inet.c:155 inet_sock_destruct+0x122/0x13a()
Date: Tue, 04 Aug 2009 08:18:34 +0200
Message-ID: <4A77D2BA.3040304@gmail.com>
References: <4A76A009.40605@wpkg.org>	<1249346282.6479.5.camel@merlyn> <20090803.212007.253928711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.dykstra1@gmail.com, mangoo@wpkg.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37876 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932428AbZHDGSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 02:18:43 -0400
In-Reply-To: <20090803.212007.253928711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: John Dykstra <john.dykstra1@gmail.com>
> Date: Mon, 03 Aug 2009 19:38:01 -0500
>=20
>> There's a good chance e51a67a9c8a2ea5c563f8c2ba6613fe2100ffe67 from =
the
>> current mainline will fix this problem.
>>
>> Dave, Eric's fix might be a candidate for -stable.  The symptom is
>> usually a WARN, but the impact is significant.
>=20
> Hmmm, I'll double-check.  I thought I had submitted this one.
>=20
> Thanks for the heads up.

Hmm, I dont see how this patch could solve Tomasz case...
Since commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
(net: No more expensive sock_hold()/sock_put() on each tx)
was not part of 2.6.30.4 AFAIK

This is the WARN_ON(sk->sk_forward_alloc) that triggers...

Sounds like a truesize mismatch rather than a sk_refcount one ?
