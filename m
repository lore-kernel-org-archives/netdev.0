From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf, skb_do_redirect: clear sender_cpu before
 xmit
Date: Fri, 9 Oct 2015 21:56:07 -0700
Message-ID: <56189A67.6080109@plumgrid.com>
References: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net>
 <56153E6C.9050202@plumgrid.com>
 <CADe=ujYvfU_h46cQXiG6Vt1iZfs+A7fYqeZ_vWtob2Kef08ukQ@mail.gmail.com>
 <561727D5.2070001@plumgrid.com> <5617FA5A.9090406@iogearbox.net>
 <561883CB.4030808@plumgrid.com>
 <1444451914.27760.116.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	"Devon H. O'Dell" <dho@fastly.com>, davem@davemloft.net,
	edumazet@google.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35702 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbbJJE4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 00:56:10 -0400
Received: by pabve7 with SMTP id ve7so46089778pab.2
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 21:56:10 -0700 (PDT)
In-Reply-To: <1444451914.27760.116.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/9/15 9:38 PM, Eric Dumazet wrote:
> On Fri, 2015-10-09 at 20:19 -0700, Alexei Starovoitov wrote:
>
>> since this bug wasn't fixed at once in all places, it means
>> that it is hard to review _all_ needed call-sites.
>> There are 7 places that call skb_sender_cpu_clear() in net-next.
>> Plus 2 more in net.
>> How many such paths from rx to tx left?
>> On the first glance ovs is missing one and who knows what else.
>
> Alexei, what's happening ?
>
> The original patch is 6 months old. If this issue was so urgent, how
> comes it took so long to catch the remaining bugs ?

no urgency at all. bpf side is clean, so I'm not worried :)

> Just add skb_sender_cpu_clear() where needed, thanks.
>
> Using union is hard, but there is a price to performance.
>
> skb size is absolutely critical and deserves some headaches.

yep. as I said it shouldn't be increased and proposed in-band sign bit.

Anyway, since you and Daniel are ok with adding skb_sender_cpu_clear()
in other places, I rest my case.
