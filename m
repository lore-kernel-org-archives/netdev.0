From: Dimitris Michailidis <dmichail@google.com>
Subject: Re: [PATCH] ipv6: fix flow labels when the traffic class is non-0
Date: Mon, 30 Jan 2017 15:38:15 -0800
Message-ID: <CAG76Sja79BR2JVop2cPxJEOzu7zTjC+F61t8m01Tf4R8Q28fDw@mail.gmail.com>
References: <20170130220942.19105-1-dmichail@google.com> <CANn89iLUfp7Y+LkvZ80UsFEw8VZ23=F6_SDyPzpbyAvxxoNeLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:37841 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751123AbdA3XjC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 18:39:02 -0500
Received: by mail-it0-f54.google.com with SMTP id r185so113825894ita.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 15:38:21 -0800 (PST)
In-Reply-To: <CANn89iLUfp7Y+LkvZ80UsFEw8VZ23=F6_SDyPzpbyAvxxoNeLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 2:23 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Mon, Jan 30, 2017 at 2:09 PM, Dimitris Michailidis
> <dmichail@google.com> wrote:
>> ip6_make_flowlabel() determines the flow label for IPv6 packets. It's
>> supposed to be passed a flow label, which it returns as is if non-0 and
>> in some other cases, otherwise it calculates a new value.
>>
>> The problem is callers often pass a flowi6.flowlabel, which may also
>> contain traffic class bits.
>
> Do you have an idea which commit added this bug Dimitris ?

[Resending reply as text]

I believe it was wrong since cb1ce2ef387b01 ("ipv6: Implement
automatic flow label generation on transmit"), the commit that
introduced ip6_make_flowlabel(). The function was somewhat different
at the time but it was doing

       if (!flowlabel && (autolabel || net->ipv6.sysctl.auto_flowlabels)) {
       ...
       }
       return flowlabel;

 and all the callers were passing flowi6.flowlabel.
