From: Eric Dumazet <edumazet@google.com>
Subject: Re: [BUG] skb corruption and kernel panic at forwarding with fragmentation
Date: Thu, 7 Jan 2016 14:47:06 -0500
Message-ID: <CANn89iJ=09fL7NZhGGtt8+jgExckHkCFC=eFiNVEMiHoK5oOcA@mail.gmail.com>
References: <CALYGNiP-0MZ-FExV2HutTvE9U-QQtkKSoE--KN=JQE5STYsjAA@mail.gmail.com>
	<CAM_iQpWsx6w2tFvSAy66M69FNi5iSp===EFCrO=4EPjy7y3iSg@mail.gmail.com>
	<CALYGNiOjeh4Jfvmc6fJHaZYJyinXmZjTHXcacNreBXvzB1ajtQ@mail.gmail.com>
	<20160106210532.GE27290@indiana.gru.redhat.com>
	<20160106220334.GA23789@breakpoint.cc>
	<20160106234943.GB23789@breakpoint.cc>
	<CALYGNiObS1fuDNi7Q69BwoWmU8xOnndzy7Z-m35aphjQWUuEnQ@mail.gmail.com>
	<CALYGNiN-cGxcEwiN-aPH7W1Pa7bLc2UY5LY98mXr+yZK+q5_BA@mail.gmail.com>
	<CANn89iLDRxh4x9hLyis2w7DfdA+0XZBhygN5gKFVA8nAgS-URQ@mail.gmail.com>
	<CALYGNiOLhaY8mom01REK45O0fO=xLNgQUt4_tox9ymrqraNfAQ@mail.gmail.com>
	<CANn89iJA=mJ+Jz-03p8yBtp6oCBE6ShwW-KW-0bpMx8OdA8whg@mail.gmail.com>
	<CALYGNiMUVjH4K3xtzHjf3o5XujFvVFrEvbL90o_fzEU8bWoQgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38691 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616AbcAGTrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:47:08 -0500
Received: by mail-wm0-f45.google.com with SMTP id b14so140307809wmb.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 11:47:07 -0800 (PST)
In-Reply-To: <CALYGNiMUVjH4K3xtzHjf3o5XujFvVFrEvbL90o_fzEU8bWoQgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 7, 2016 at 2:35 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> On Thu, Jan 7, 2016 at 3:54 PM, Eric Dumazet <edumazet@google.com> wrote:
 want to look at git history to find out why it is done this way.
>>
>> TCP performance is critical for some of us, and doing such trick avoid
>> one cache miss per skb in some critical list traversals.
>
> Right. This way tcp stuff perfectly fits into leftovers of first cache line.
> Then probably it's better to put ipv4/ipv6 cb into second line from
> the beginning.

Then IP forwarding might be slower.

Look, each layer (TCP  , IP, ....) can organize its skb->cb[] as it wants.
Nobody tries to 'make universal room' for IPCB, since only IP layer wants it.

TCP could even find a way in the future to no longer hold a copy of
IPCB in the input skb,
if code is reorganized a bit.

Note that skbs for output path in TCP do not need IPCB at all.

Only when skb leaves TCP and enter IP, skb->cb[] content is scratched.
