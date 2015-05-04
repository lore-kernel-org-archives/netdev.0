From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next v2 2/3] ipvlan: Process fragmented multicast frames correctly
Date: Mon, 4 May 2015 15:58:59 -0700
Message-ID: <CAF2d9jhESPaPCtRsh7GWUY9Kue2h2D0Nw2Qv1H=Gj15M3twN0w@mail.gmail.com>
References: <1430331558-20286-1-git-send-email-maheshb@google.com> <20150501.211225.641281069847184355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, dcbw@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:36161 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbbEDW7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 18:59:20 -0400
Received: by obbkp3 with SMTP id kp3so62609550obb.3
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 15:59:19 -0700 (PDT)
In-Reply-To: <20150501.211225.641281069847184355.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 1, 2015 at 6:12 PM, David Miller <davem@davemloft.net> wrote:
> From: Mahesh Bandewar <maheshb@google.com>
> Date: Wed, 29 Apr 2015 11:19:18 -0700
>
>> Multicast processing in IPvlan was faulty as is. Eric Dumazet
>> pointed out that fragmented packets won't be processed correctly
>> unless defrag step is introduced.
>>
>> This patch adds the defrag step before driver attempts to process
>> multicast frame(s).
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>
> And now you are potentially modifying the geometry of packets that
> traverse ipvlan devices.
>
Yes, that is true but to optimize the fragments processing.

> I am sorry but I am going to put my foot down and not allow another
> instance of this to happen again.  We already have this being done by
> netfilter, and I consider it unacceptable as well as inefficient.
>
Actually this will make the fragments processing more efficient. e.g.
if there are 50 slave devices and we receive 10 fragments, the
duplication will happen for 50*10 = 500 skbs but if the packet is
defragmented, then it's only once per device making it more efficient.

> If a fragmented frame is going to be forwarded by us, defragmenting
> and refragmenting may create a different outgoing packet stream than
> what arrived.  If the outgoing interface's MTU can accomodate the
> incoming frames, this kind of modification is absolutely forbidden.

I understand the concern (after going though Florian Westphal's patch
series) and will take this patch off of this series until matter
settles. Also trying to optimize slow path (fragments) is not very
high on the priority list in any case.

Thanks,
--mahesh..
