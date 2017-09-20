From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH net-next 07/14] gtp: Support encapsulation of IPv6 packets
Date: Tue, 19 Sep 2017 17:11:54 -0700
Message-ID: <CAPDqMeq6b+e7H1aSquR77bKm8EXu59AzU9OPw=8aHNf1e5-MFA@mail.gmail.com>
References: <20170919003904.5124-8-tom@quantonium.net> <20170918.211908.2152170523885516973.davem@davemloft.net>
 <20170919121245.t555dqwndhewmdyw@nataraja> <20170919.104248.1540128186724107742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Harald Welte <laforge@gnumonks.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Rohit LastName <rohit@quantonium.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:43571 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751074AbdITALz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 20:11:55 -0400
Received: by mail-wm0-f43.google.com with SMTP id a137so2205153wma.0
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 17:11:55 -0700 (PDT)
In-Reply-To: <20170919.104248.1540128186724107742.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 10:42 AM, David Miller <davem@davemloft.net> wrote:
> From: Harald Welte <laforge@gnumonks.org>
> Date: Tue, 19 Sep 2017 20:12:45 +0800
>
>> Hi Dave,
>>
>> On Mon, Sep 18, 2017 at 09:19:08PM -0700, David Miller wrote:
>>
>>> > +static inline u32 ipv6_hashfn(const struct in6_addr *a)
>>> > +{
>>> > +  return __ipv6_addr_jhash(a, gtp_h_initval);
>>> > +}
>>>
>>> I know you are just following the pattern of the existing "ipv4_hashfn()" here
>>> but this kind of stuff is not very global namespace friendly.  Even simply
>>> adding a "gtp_" prefix to these hash functions would be a lot better.
>>
>> I would agree if this was an inline function defined in a header file or
>> a non-static function.  But where is the global namespace concern in
>> case of static inline functions defined and used in the same .c file?
>
> The problem is if we create a generic ipv6_hashfn() in linux/ipv6.h or
> something like that, then this driver stops building.

It was a carry over since ipv4_hashfn was already defined in the file.
I will prefix both functions.
