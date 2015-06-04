From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next] bpf: introduce bpf_clone_redirect() helper
Date: Thu, 4 Jun 2015 09:45:13 +0300
Message-ID: <CAJ3xEMgqw3Kj5SdBDsyr18z_n4n6BeOJLcjK2iMnaqMwuJ+tEw@mail.gmail.com>
References: <1433286194-5246-1-git-send-email-ast@plumgrid.com>
	<20150603.201727.1848194519762843477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34424 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbbFDGpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 02:45:14 -0400
Received: by oifu123 with SMTP id u123so24768724oif.1
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 23:45:14 -0700 (PDT)
In-Reply-To: <20150603.201727.1848194519762843477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 4, 2015 at 6:17 AM, David Miller <davem@davemloft.net> wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Tue,  2 Jun 2015 16:03:14 -0700
>
>> Allow eBPF programs attached to classifier/actions to call
>> bpf_clone_redirect(skb, ifindex, flags) helper which will
>> mirror or redirect the packet by dynamic ifindex selection
>> from within the program to a target device either at ingress
>> or at egress. Can be used for various scenarios, for example,
>> to load balance skbs into veths, split parts of the traffic
>> to local taps, etc.
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>
> Applied, thanks.

build fails on my setup...

CC [M]  net/core/pktgen.o
net/core/filter.c: In function 'bpf_clone_redirect':
net/core/filter.c:1429: error: 'struct sk_buff' has no member named 'tc_verd'

you use skb->tc_verd but this code snippest goes along without being
dependent on CONFIG_NET_CLS_ACT
