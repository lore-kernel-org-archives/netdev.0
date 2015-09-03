From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2] net: Fix behaviour of unreachable, blackhole and
 prohibit routes
Date: Thu, 3 Sep 2015 15:22:35 -0700
Message-ID: <55E8C82B.6000208@gmail.com>
References: <1441271331.3360.36.camel@redhat.com>
 <20150903.102955.927476775467830647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, nforro@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:32864 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026AbbICWWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 18:22:37 -0400
Received: by iofh134 with SMTP id h134so4369657iof.0
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2015 15:22:37 -0700 (PDT)
In-Reply-To: <20150903.102955.927476775467830647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2015 10:29 AM, David Miller wrote:
> From: Nikola Forr=F3 <nforro@redhat.com>
> Date: Thu, 03 Sep 2015 11:08:51 +0200
>
>> @@ -233,8 +233,10 @@ static inline int fib_lookup(struct net *net, c=
onst struct flowi4 *flp,
>>   	rcu_read_lock();
>>  =20
>>   	tb =3D fib_get_table(net, RT_TABLE_MAIN);
>> -	if (tb && !fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF=
))
>> -		err =3D 0;
>> +	if (tb)
>> +		err =3D fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF);
>> +		if (err =3D=3D -EAGAIN)
>> +			err =3D -ENETUNREACH;
> You didn't test this.

Actually the way the code is structured is still functional this way. =20
The indentation is all that is really wrong.

I suspect this actually results in smaller code that may be faster for=20
the standard case since tb will almost always have a value anyway, and=20
if tb doesn't exist then err would equal -ENETUNREACH which would just=20
mean the err =3D=3D -EAGAIN would be ignored.

- Alex
