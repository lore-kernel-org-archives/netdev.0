From: Marcelo <marcelo.leitner@gmail.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Thu, 03 Dec 2015 16:06:11 -0200
Message-ID: <74ED362E-9B4D-48CB-85BE-04DEDF1BFC97@gmail.com>
References: <CACT4Y+ZnWRZfQC25uW=GXHAJB=GX0L6tJQUy43P6WNR3=hwT8Q@mail.gmail.com> <CACT4Y+aAYy4-Ow+gt+1C46CK1+MbspBMM7qz9pVYsXvGXRJ1SQ@mail.gmail.com> <CACT4Y+YjAhRSYDFUZYydtWfRzi1yDEKtPrPsJqYN93Km91J=Cw@mail.gmail.com> <20151124204553.GB3364@hmsreliant.think-freely.org> <5655CFDC.4050206@gmail.com> <CACT4Y+aNgjykBXxEM0uv0MPOa=N6zkBuEp+vShR3KHqRE-tPAw@mail.gmail.com> <20151203165133.GD4164@mrl.redhat.com> <20151203174356.GE4164@mrl.redhat.com> <1449165550.25029.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Vyukov <dvyukov@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:33433 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbbLCSGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 13:06:41 -0500
In-Reply-To: <1449165550.25029.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Em 3 de dezembro de 2015 15:59:10 BRST, Eric Dumazet <eric.dumazet@gmail.com> escreveu:
>On Thu, 2015-12-03 at 15:43 -0200, Marcelo Ricardo Leitner wrote:
>
>> Vlad, others,
>> 
>> It's been a long time but this was introduced by commit 914e1c8b6980
>> ("sctp: Inherit all socket options from parent correctly."). This is
>not
>> very consistent with how other protocols work and it will be hard to
>> keep tracking a negative mask of flags that we can't copy.
>> 
>> I reviewed the list of options and I'm thinking that only
>> SO_BINDTODEVICE is worth copying, leaving the others for the
>application
>> to re-set, as it is for other protocols. So I'm thinking on simply:
>> 
>> -       newsk->sk_flags = sk->sk_flags;
>> +       newsk->sk_flags = sk->sk_flags & SO_BINDTODEVICE;
>> 
>> in the above.
>> 
>> What do you think?
>
>I think SO_BINDTODEVICE is not a flag ;)
>
>#define SO_BINDTODEVICE    25

Oops, indeed!
Idea persists.
Thx!
-- 
Sent from mobile. Please excuse my brevity.
