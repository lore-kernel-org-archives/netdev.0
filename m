From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/tcp: null-ptr-deref in __inet_lookup_listener/inet_exact_dif_match
Date: Wed, 2 Nov 2016 19:36:47 +0100
Message-ID: <CAAeHK+xve4FkRhk01CA0dq9iaYqcUi23dMd42GKNzT7+nt7FJw@mail.gmail.com>
References: <CAAeHK+z9bqpWqONBBL1rztkY-+NdzY4jfCzNzfnm63psxbW-2g@mail.gmail.com>
 <1478107305.7065.382.camel@edumazet-glaptop3.roam.corp.google.com> <f92b8a3e-9318-90c4-009a-15da3897ff6b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f92b8a3e-9318-90c4-009a-15da3897ff6b@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

I'm able to reproduce it, so I'd be happy to test your fix.

Thanks!

On Wed, Nov 2, 2016 at 7:31 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 11/2/16 11:21 AM, Eric Dumazet wrote:
>> Thanks for your report.
>>
>> David, please take a look.
>>
>> TCP MD5 can call __inet_lookup_listener() with a NULL skb.
>
> interesting. I did not test md5 before sending, but doing so now I am not able to trigger the panic with any combination of passwords - correct, wrong, none, no listener, etc. perhaps I am missing a sysctl setting.
>
> Will send a fix. I see the call to __inet_lookup_listener with null skb.
>
>>
>> Bug added in commit a04a480d4392ea6efd117be2de564117b2a009c0
>
