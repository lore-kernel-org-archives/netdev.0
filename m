From: =?UTF-8?B?Q2h1bmctWWloIFdhbmcgKOeOi+W0h+aHvyk=?=
	<cywang@google.com>
Subject: Re: Regarding to your linux kernel CL
Date: Wed, 6 Oct 2010 14:23:44 -0700
Message-ID: <AANLkTin3o_83kz1OxsN1Pme=0wv0g1zJ2F+FQ+U--u5e@mail.gmail.com>
References: <AANLkTikdcL0JQgkR6u0qtmDu-phMZ6-Juq91B1N5GfiY@mail.gmail.com>
 <4CAC1F20.6070009@iki.fi> <20101006075946.GA5311@gondor.apana.org.au> <20101006.011448.112578977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: herbert@gondor.hengli.com.au, timo.teras@iki.fi,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:12349 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933140Ab0JFVYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 17:24:08 -0400
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o96LO6gF001842
	for <netdev@vger.kernel.org>; Wed, 6 Oct 2010 14:24:06 -0700
Received: from vws19 (vws19.prod.google.com [10.241.21.147])
	by wpaz21.hot.corp.google.com with ESMTP id o96LMVKJ014944
	for <netdev@vger.kernel.org>; Wed, 6 Oct 2010 14:24:05 -0700
Received: by vws19 with SMTP id 19so22014vws.18
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 14:24:05 -0700 (PDT)
In-Reply-To: <20101006.011448.112578977.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do you mean if we should move the genid/cookie logic into sk_dst_check
and remove the dst->ops->check()? If so, I dont think it will be a
good idea to remove 'dst->ops->check' since it is per dst entry's
check not just for ipv4 entry. At least, the fact of obsolete=2
reveals that the entry is freed and is ready for being released. That
will be weird if we still use the obsolete entry for routing the
socket's traffic(for sure, that's why the packets of the socket goes
nowhere but dropped).

On Wed, Oct 6, 2010 at 1:14 AM, David Miller <davem@davemloft.net> wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 6 Oct 2010 15:59:46 +0800
>
>> Perhaps we should move the genid/cookie logic into the dst so that
>> we can eliminate the dst->check call or at least make it a lot less
>> frequent.
>
> That sounds like a good idea.
>
