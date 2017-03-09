From: Jonathan Maxwell <jmaxwell37@gmail.com>
Subject: Re: [PATCH net] dccp/tcp: fix routing redirect race
Date: Thu, 9 Mar 2017 15:47:16 +1100
Message-ID: <CAGHK07Bn1qJenWUae8yQfU5iZ35QtivY=Hh0ZpqpsSnLTaZoZQ@mail.gmail.com>
References: <1489022121-20571-1-git-send-email-jmaxwell37@gmail.com>
 <1489025457.28631.19.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAGHK07BME+defjxsZZPFxyo2wEgbD2gJKMDerawCS4aLN3RdVA@mail.gmail.com> <1489034454.28631.21.camel@edumazet-glaptop3.roam.corp.google.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36625 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbdCIEuZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 23:50:25 -0500
In-Reply-To: <1489034454.28631.21.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 9, 2017 at 3:40 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-03-09 at 14:42 +1100, Jonathan Maxwell wrote:
>> Sorry let me resend in plain text mode.
>>
>> On Thu, Mar 9, 2017 at 1:10 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Thu, 2017-03-09 at 12:15 +1100, Jon Maxwell wrote:
>> >> We have seen a few incidents lately where a dst_enty has been freed
>> >> with a dangling TCP socket reference (sk->sk_dst_cache) pointing to that
>> >> dst_entry. If the conditions/timings are right a crash then ensues when the
>> >> freed dst_entry is referenced later on. A Common crashing back trace is:
>> >
>> > Very nice catch !
>> >
>>
>> Thanks Eric.
>>
>> > Don't we have a similar issue for IPv6 ?
>> >
>> >
>>
>> Good point.
>>
>> We checked and as far as we can tell IPv6 does not invalidate the route.
>> So it should be safer.
>
> Simply doing :
>
> __sk_dst_check(sk, np->dst_cookie);
>
> is racy, even before calling dst->ops->redirect(dst, sk, skb);
>
> (if socket is owned by user)
>
>
>

Okay, I will add a similar patch for IPv6 to also protect from that.
