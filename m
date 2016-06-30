From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH net] bonding: prevent out of bound accesses
Date: Thu, 30 Jun 2016 16:13:37 +0200
Message-ID: <CACT4Y+Y=1T_iYGL83bL8pN2QtC8-jiiGXyG0qLmpeOE8R3WX5w@mail.gmail.com>
References: <1467291379.11238.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+aAVS+oYg62hftq7RMb2QM9wiPCK-Vf33c2PaG2Sm6R6g@mail.gmail.com>
 <1467293149.11238.12.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+YdOi1-z1pPJaYBybyHZ=MXzHPGjGU+UJWJf-N3pgGzeg@mail.gmail.com> <1467295729.11238.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Ding Tianhong <dingtianhong@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:34122 "EHLO
	mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbcF3ON6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 10:13:58 -0400
Received: by mail-lf0-f44.google.com with SMTP id h129so56480963lfh.1
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 07:13:57 -0700 (PDT)
In-Reply-To: <1467295729.11238.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 4:08 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-06-30 at 15:35 +0200, Dmitry Vyukov wrote:
>
>>
>> What does nm -S say?
>> I've tried to compile a sample program with gcc6 and
>> __attribute__((aligned(8))) does in fact force alignment of start of
>> the symbol, but size still stays 6. (and asan still barks on my test
>> program).
>
> Right, but then it means I also need to change mac_bcast[] and
> mac_v6_allmcast[] in bond_alb.c to avoid false positive.
>
> (Technically, if their alignment is 8, we have 8 bytes there,
> no way it could span 2 pages)

Agree.

> I'll send a v2.

Thanks!
