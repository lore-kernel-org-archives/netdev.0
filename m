From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [IPV4] ROUTE: Avoid sparse warnings
Date: Tue, 8 Jan 2008 13:59:02 +0100
Message-ID: <20080108125902.GB1920@ff.dom.local>
References: <47832BE6.5070906@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:6348 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094AbYAHMw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 07:52:58 -0500
Received: by fk-out-0910.google.com with SMTP id z23so9110052fkz.5
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2008 04:52:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47832BE6.5070906@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08-01-2008 08:53, Eric Dumazet wrote:
> David Miller a =E9crit :
=2E..
>> Furthermore, these:
>>
>>     rcu_read_unlock_bh()
>>     rcu_read_lock_bh()
>>
>> sequences are at best funny looking.  For other lock types we would
>> look at this and ask "Does this even accomplish anything reliably?"
>=20
> Well, original code exactly does the same thing.
>=20
>>
>> The answer here is that it wants the preempt_enable() to run to get
>> any potential kernel preemptions executed.  It also allows any
>> pending software interrupts to run.
>>
>> So this does something reliably only because rcu_read_unlock_bh() ha=
s
>> specific and explicit side effects.
>>
>=20
> I will post a patch to introduce a helper function, so that this is=20
> clearly documented and not relying on side effects. Actual=20
> implementation has latency
> problems on empty hash tables if CONFIG_PREEMPT=3Dn
>=20
>=20
>> I don't know, to me it just looks awful :-)  I better understood the
>> original code.

It seems this patch only made it more visible how it currently works.
I don't know what changes do you plan for this helper function, but
my proposal is to add some counter and break this rcu only after
looping for some time. Alternatively cpu_relax() could be probably
used between these "locks". Without this probably some cache problems
are possible, but you know this better, I guess.

Regards,
Jarek P.
