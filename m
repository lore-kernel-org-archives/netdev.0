From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] ipv6: ensure message length for raw socket is at least sizeof(ipv6hdr)
Date: Tue, 25 Apr 2017 11:10:22 -0700
Message-ID: <CANn89iJ8gyhM+9pfJLnoth1e2BtNxJXtFOYs8nGoOTwJ5uGyqA@mail.gmail.com>
References: <20170425131827.66498-1-glider@google.com> <20170425.135543.1706004185593424024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170425.135543.1706004185593424024.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 25, 2017 at 10:55 AM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Potapenko <glider@google.com>
> Date: Tue, 25 Apr 2017 15:18:27 +0200
>
>> rawv6_send_hdrinc() expects that the buffer copied from the userspace
>> contains the IPv6 header, so if too few bytes are copied parts of the
>> header may remain uninitialized.
>>
>> This bug has been detected with KMSAN.
>>
>> Signed-off-by: Alexander Potapenko <glider@google.com>
>
> Hmmm, ipv4 seems to lack this check as well.
>
> I think we need to be careful here and fully understand why KMSAN doesn't
> seem to be triggering in the ipv4 case but for ipv6 it is before I apply
> this.

This could be a bug in nf_ct_frag6_gather() missing one pskb_may_pull()
