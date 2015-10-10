From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf, skb_do_redirect: clear sender_cpu before
 xmit
Date: Fri, 9 Oct 2015 20:19:39 -0700
Message-ID: <561883CB.4030808@plumgrid.com>
References: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net>
 <56153E6C.9050202@plumgrid.com>
 <CADe=ujYvfU_h46cQXiG6Vt1iZfs+A7fYqeZ_vWtob2Kef08ukQ@mail.gmail.com>
 <561727D5.2070001@plumgrid.com> <5617FA5A.9090406@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"Devon H. O'Dell" <dho@fastly.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33908 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbbJJDTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 23:19:42 -0400
Received: by padhy16 with SMTP id hy16so102740849pad.1
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 20:19:41 -0700 (PDT)
In-Reply-To: <5617FA5A.9090406@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/9/15 10:33 AM, Daniel Borkmann wrote:
>> I was thinking may be we can use sign bit to distinguish between
>> napi_id and sender_cpu.
>> Like:
>>          if ((int)skb->sender_cpu >= 0)
>>                  skb->sender_cpu = - (raw_smp_processor_id() + 1);
>> and inside get_xps_queue() use it only if it's negative.
>> Then we can remove skb_sender_cpu_clear() from everywhere.
>> Adding a check to napi_hash_add() to make sure that napi_id is not
>> negative is probably ok too.
>> Thoughts?
>
> I think this doesn't make it any more maintainable.
>
> skb_sender_cpu_clear(), one can at least git-grep to easily find
> out and review call-sites in the code. There are various members
> already used differently depending on the context.

since this bug wasn't fixed at once in all places, it means
that it is hard to review _all_ needed call-sites.
There are 7 places that call skb_sender_cpu_clear() in net-next.
Plus 2 more in net.
How many such paths from rx to tx left?
On the first glance ovs is missing one and who knows what else.
