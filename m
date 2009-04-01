From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] x86: percpu_to_op() misses memory and flags clobbers
Date: Wed, 01 Apr 2009 20:47:41 +0200
Message-ID: <49D3B6CD.2030908@cosmosbay.com>
References: <49D32212.80607@cosmosbay.com> <49D32DC2.9010003@goop.org> <49D33E80.70802@cosmosbay.com> <20090401161218.GB3859@elte.hu> <49D3A0C2.9000403@cosmosbay.com> <49D3AD61.5090206@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Tejun Heo <htejun@gmail.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33364 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933682AbZDASsA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 14:48:00 -0400
In-Reply-To: <49D3AD61.5090206@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeremy Fitzhardinge a =E9crit :
> Eric Dumazet wrote:
>> +#define percpu_inc(var)        percpu_to_op0("inc", per_cpu__##var)
>> +#define percpu_dec(var)        percpu_to_op0("dec", per_cpu__##var)
>>  =20
>=20
> There's probably not a lot of value in this.  The Intel and AMD
> optimisation guides tend to deprecate inc/dec in favour of using
> add/sub, because the former can cause pipeline stalls due to its part=
ial
> flags update.
>=20
>    J

Sure, but this saves one byte per call, this is probably why we still u=
se
inc/dec in so many places...

