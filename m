From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Sat, 3 May 2014 13:39:37 +0200
Message-ID: <CAKgNAkhLDxpBZ0yu+Ab3b1LOw4XZe6MSn03wBANykzDw9C8NFg@mail.gmail.com>
References: <536101C9.9090601@gmail.com> <CAKgNAkhaFoMMzo1JB7wfgZ2Qwkgjvf8Tp8c77ih99=1qcDoNKg@mail.gmail.com>
 <20140503112905.GC3514@breakpoint.cc>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"linux-man@vger.kernel.org" <linux-man@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?T25kxZllaiBCw61sa2E=?= <neleai@seznam.cz>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Elie De Brauwer <eliedebrauwer@gmail.com>,
	David Miller <davem@davemloft.net>,
	Steven Whitehouse <steve@chygwyn.com>,
	=?UTF-8?Q?R=C3=A9mi_Denis=2DCourmont?=
	<remi.denis-courmont@nokia.com>, Paul Moore <paul@paul-moore.com>,
	Chris Friesen <chris.friesen@windriver.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140503112905.GC3514@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 3, 2014 at 1:29 PM, Florian Westphal <fw@strlen.de> wrote:
> Michael Kerrisk (man-pages) <mtk.manpages@gmail.com> wrote:
>> Reinvestigating the problem, I see that I got my description of the
>> behavior slightly wrong, although the fundamental problem remains.
>> Here's my improved formulation:
> [..]
>
>> Since the timeout is only checked after the arrival of each datagram,
>> we can have scenarios like the following:
>>
>> 0. Assume a timeout of 10 (T) seconds, that vlen is 5, and the call
>>    is made at time X
>>
>> 1. First datagram arrives at time X+2.
>>
>> 2. Second datagram arrives at time X+4 secs
>>
>> 3. Third datagram arrives at time X+6 secs
>>
>> 4. No more datagrams arrive.
>>
>> In this case, the call blocks forever. It hardly seems that this could
>> be intended behavior. The problem, of course is that the timeout is
>> checked only after receipt of a datagram.
>
> Isn't that what MSG_WAITFORONE is supposed to solve?

I don't think so. I understand the idea of the timeout to be: get as
many datagrams as you can within a certain interval. MSG_WAITFORONE is
orthogonal to that goal (you can specify MSG_WAITFORONE without an
infiniite timeout, for example).

Also, consider the algorithm above: if no datagrams arrive, the
timeout is in effect ignored.

Thanks,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
