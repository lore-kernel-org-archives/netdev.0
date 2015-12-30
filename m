From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] net: Fix potential NULL pointer dereference in __skb_try_recv_datagram
Date: Wed, 30 Dec 2015 09:38:48 -0500
Message-ID: <CANn89i+1=7JgRQZ2J+MHYgx1KOJWbWv2rODveyJSR+ybk3HPjQ@mail.gmail.com>
References: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
	<87y4cdyrbn.fsf@doppelsaurus.mobileactivedefense.com>
	<20151229.150843.2021692616139434395.davem@davemloft.net>
	<CAEnXRPtJBoOn+JgXDEUdL07WkbYVViAT_+LBiV4X=NVQ3SiDaQ@mail.gmail.com>
	<CANn89iLpuz4nP+hPoGUHY8KSv=GwSE1x13D3qDeAQDJjV-S7pw@mail.gmail.com>
	<CAEnXRPsVe5ROz=Vo0fTODrs3EsEWoU1hzHVvyEwMyMCrE3BwDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Al Viro <viro@zeniv.linux.org.uk>,
	LKML <linux-kernel@vger.kernel.org>
To: Jacob Siverskog <jacob@teenage.engineering>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEnXRPsVe5ROz=Vo0fTODrs3EsEWoU1hzHVvyEwMyMCrE3BwDA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 30, 2015 at 9:30 AM, Jacob Siverskog
<jacob@teenage.engineering> wrote:
> On Wed, Dec 30, 2015 at 2:26 PM, Eric Dumazet <edumazet@google.com> wrote:

>> At this point corruption already happened.
>> We can not possibly detect every possible corruption caused by bugs
>> elsewhere in the kernel and just 'recover' at this point.
>> We must indeed find the root cause and fix it, instead of trying to hide it.
>>
>> How often can you trigger this bug ?
>
> Ok. I don't have a good repro to trigger it unfortunately, I've seen it just a
> few times when bringing up/down network interfaces. Does the trace
> give any clue?
>
> [<c02fc0a8>] (__skb_recv_datagram) from [<c0398f1c>] (udpv6_recvmsg+0x1d0/0x6d0)
> [<c0398f1c>] (udpv6_recvmsg) from [<c0367a2c>] (inet_recvmsg+0x38/0x4c)
> [<c0367a2c>] (inet_recvmsg) from [<c02efff4>] (___sys_recvmsg+0x94/0x170)
> [<c02efff4>] (___sys_recvmsg) from [<c02f0d74>] (__sys_recvmsg+0x3c/0x6c)
> [<c02f0d74>] (__sys_recvmsg) from [<c000f1e0>] (ret_fast_syscall+0x0/0x3c)

Not really : it only shows the point where the corruption is detected,
not the point where the corruption happened.

This might be caused by a netfilter module, a buggy driver... it is
hard to know.

You might add some traces on the skb itself, like its length or/and content.
