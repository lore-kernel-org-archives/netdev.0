From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf, skb_do_redirect: clear sender_cpu before
 xmit
Date: Fri, 9 Oct 2015 20:11:51 -0700
Message-ID: <561881F7.2070304@plumgrid.com>
References: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net>
 <56153E6C.9050202@plumgrid.com>
 <CADe=ujYvfU_h46cQXiG6Vt1iZfs+A7fYqeZ_vWtob2Kef08ukQ@mail.gmail.com>
 <561727D5.2070001@plumgrid.com>
 <CADe=ujZWjibL39JXM4U32GSHjK_sc6oov1Z0KrTL2dMGryJCjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: "Devon H. O'Dell" <dho@fastly.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33464 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbbJJDLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 23:11:53 -0400
Received: by pacex6 with SMTP id ex6so103116933pac.0
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 20:11:52 -0700 (PDT)
In-Reply-To: <CADe=ujZWjibL39JXM4U32GSHjK_sc6oov1Z0KrTL2dMGryJCjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/9/15 9:40 AM, Devon H. O'Dell wrote:
> I like the idea, but it seems unnecessarily magical. What about using
> a bitfield? Then there's just an option bit that is either
> OPTION_NAPI_ID or OPTION_SENDER_CPU. Then the check to set sender_cpu
> in netdev_pick_tx becomes
>
>      if (skb->sender_napi_option == OPTION_NAPI_ID || skb->sender_cpu == 0) ..

It's less magical, but slower since two loads from skb and two cmp/jmp
are needed instead of one.
and this is critical path of xmit executed for every skb.
that's why I proposed a sign.
