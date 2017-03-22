From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v7 2/3] Add a eBPF helper function to retrieve
 socket uid
Date: Wed, 22 Mar 2017 21:06:47 +0900
Message-ID: <CAKD1Yr3o_Vp80FLbG5-9B7Ldag7sZOj4CHKjRWO-SfBL=ZS0pw@mail.gmail.com>
References: <1490133934-7055-1-git-send-email-chenbofeng.kernel@gmail.com>
 <1490133934-7055-3-git-send-email-chenbofeng.kernel@gmail.com> <CAF=yD-+D5oHcU3qq4nDDWE1Bt4k2Vv9Ekf=FoKMdrc0F5dGS_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:34710 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934256AbdCVMHJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 08:07:09 -0400
Received: by mail-vk0-f46.google.com with SMTP id z204so65740559vkd.1
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 05:07:08 -0700 (PDT)
In-Reply-To: <CAF=yD-+D5oHcU3qq4nDDWE1Bt4k2Vv9Ekf=FoKMdrc0F5dGS_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 22, 2017 at 8:09 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
>> +       if (!sk || !sk_fullsock(sk))
>> +               return overflowuid;
>> +       kuid = sock_net_uid(sock_net(sk), sk);
>> +       return from_kuid_munged(&init_user_ns, kuid);
>
> Ideally, this would be the user namespace relative to the BPF program.

What about sock_net(sk)->user_ns? We've already matched a socket, and
it's guaranteed to be a full socket and non-NULL (otherwise we've
already returned overflowuid), so it seems like the most correct
namespace to use is the one of the socket we've matched. Given that sk
is non-NULL, sock_net_uid just returns sk->sk_uid, so I think you can
just write this as:

if (!sk || !sk_fullsock(sk))
        return overflowuid;
return from_kuid_munged(sock_net(sk)->user_ns, sk->uid);
