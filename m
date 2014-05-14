From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/5] bonding: simple macro cleanup
Date: Wed, 14 May 2014 09:10:33 -0700
Message-ID: <CAADnVQKw3npBoeuQbVf4FtDiqiZuc7+1z7fwUL_6Vru-p3BwDQ@mail.gmail.com>
References: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1724466A@AcuExch.aculab.com>
	<20140514132922.GA24104@mikrodark.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:62745 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754328AbaENQKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 12:10:33 -0400
Received: by mail-qc0-f176.google.com with SMTP id r5so3115604qcx.21
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 09:10:33 -0700 (PDT)
In-Reply-To: <20140514132922.GA24104@mikrodark.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 6:29 AM, Veaceslav Falico <vfalico@gmail.com> wrote:
> On Wed, May 14, 2014 at 01:08:19PM +0000, David Laight wrote:
>>
>> From: Veaceslav Falico
>>>
>>> Hi,
>>>
>>> That's a trivial patchset that tries to unify the macro usage of bonding
>>> modes. I've split it into two approaches - either BOND_*, which takes
>>> bonding struct as a param, or MODE_*, which takes the mode itself. Also,
>>> introduce BOND_MODE(bond) instead of ugly bond->params.mode.
>>
>>
>> I'm not sure these are improvements....
>>
>> I thought that netdev (in particular) preferred static inline functions
>> to #defines - and especially #defines that expand their argument(s)
>> more than once.
>
>
> There's only one static inline function removal - which was completely
> different from the usual macros (bond_is_lb()). Other macros are just
> renames to quicker understand the code.
>
>
>>
>> IMHO Simple access functions are just a PITA when reading code since
>> they cause the reader to go off somewhere and look up the definition.
>
>
> I can make them either way, I've made this patchset while doing other
> patchset, and the basic idea was that currently the usage of these macros
> is quite illogical - some take bond as an argument, some the mode, and
> there's a function that is a macro...
>
> Anyway, I don't have a strong feeling either way, so if people think that
> it's better the way it is - I'm ok with that.

from compiler point of view it's actually easier to deal with inline functions
than macros. I'd suggest to do the full conversion the other way around:
convert all macros to static inline. Developers will enjoy better type safety
and compiler will enjoy more opportunities to optimize code.
