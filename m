From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/2] Add a eBPF helper function to retrieve socket
 uid
Date: Fri, 03 Feb 2017 01:28:31 +0100
Message-ID: <5893CEAF.2090707@iogearbox.net>
References: <20170202205950.100334-1-chenbofeng.kernel@gmail.com> <20170202205950.100334-3-chenbofeng.kernel@gmail.com> <5893A587.6090000@iogearbox.net> <CAKD1Yr30K4Yi8U0bnTOq60rPW6aYY1Vb4xxmRgZdz319UmLmRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34857 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751512AbdBCA2j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 19:28:39 -0500
In-Reply-To: <CAKD1Yr30K4Yi8U0bnTOq60rPW6aYY1Vb4xxmRgZdz319UmLmRw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2017 01:00 AM, Lorenzo Colitti wrote:
> On Fri, Feb 3, 2017 at 6:32 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>>> +       sk = skb->sk;
>>> +       kuid = sock_net_uid(dev_net(skb->dev), sk);
>>
>> Don't you need to test for fullsock? Do you mean something like below?
>
> It should be safe to call sock_net_uid on any type of socket
> (including NULL). sk_uid was added to struct sock in 86741ec25462
> ("net: core: Add a UID field to struct sock.")

Hmm, maybe I'm missing something, but then shouldn't this sit in
struct sock_common for being 'safe'? F.e. struct inet_timewait_sock
wouldn't have it ...
