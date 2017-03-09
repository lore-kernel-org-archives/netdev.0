From: Jonathan Maxwell <jmaxwell37@gmail.com>
Subject: Re: [PATCH net] dccp/tcp: fix routing redirect race
Date: Thu, 9 Mar 2017 14:42:47 +1100
Message-ID: <CAGHK07BME+defjxsZZPFxyo2wEgbD2gJKMDerawCS4aLN3RdVA@mail.gmail.com>
References: <1489022121-20571-1-git-send-email-jmaxwell37@gmail.com> <1489025457.28631.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: gerrit@erg.abdn.ac.uk, David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        kuznet <kuznet@ms2.inr.ac.ru>, jmorris <jmorris@namei.org>,
        yoshfuji <yoshfuji@linux-ipv6.org>, kaber <kaber@trash.net>,
        Neal Cardwell <ncardwell@google.com>, dccp@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jon Maxwell <jmaxwell@redhat.com>,
        Eric Garver <egarver@redhat.com>,
        Hannes Sowa <hsowa@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489025457.28631.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry let me resend in plain text mode.

On Thu, Mar 9, 2017 at 1:10 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-03-09 at 12:15 +1100, Jon Maxwell wrote:
>> We have seen a few incidents lately where a dst_enty has been freed
>> with a dangling TCP socket reference (sk->sk_dst_cache) pointing to that
>> dst_entry. If the conditions/timings are right a crash then ensues when the
>> freed dst_entry is referenced later on. A Common crashing back trace is:
>
> Very nice catch !
>

Thanks Eric.

> Don't we have a similar issue for IPv6 ?
>
>

Good point.

We checked and as far as we can tell IPv6 does not invalidate the route.
So it should be safer.
