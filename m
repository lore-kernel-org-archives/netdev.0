From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Tue, 7 Feb 2017 12:51:54 -0800
Message-ID: <CAF=yD-LiptFZCM3akz8-uMA=UH1sTbsXtWQp1=xT52YaWrfqUA@mail.gmail.com>
References: <20170127215848.GG25829@oracle.com> <CAF=yD-KqQdPVn-CFAu3ak+c3NRO9gfT+8UwXXS4eSv9ax0iAnA@mail.gmail.com>
 <20170130162603.GF3590@oracle.com> <20170130.114143.1357866047815335563.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34394 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754874AbdBGUxS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 15:53:18 -0500
Received: by mail-wm0-f66.google.com with SMTP id c85so30540380wmi.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 12:52:36 -0800 (PST)
In-Reply-To: <20170130.114143.1357866047815335563.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 8:41 AM, David Miller <davem@davemloft.net> wrote:
> From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Date: Mon, 30 Jan 2017 11:26:03 -0500
>
>> On (01/27/17 19:19), Willem de Bruijn wrote:
>>> > other than ax25, are there variable length header protocols out there
>>> > without ->validate, and which need the CAP_RAW_SYSIO branch?
>>>
>>> I don't know. An exhaustive search of protocols (by header_ops) may be
>>> needed to say for sure.
>>>
>>> If there are none, then the solution indeed is quite simple.
>>
>>
>> I tried to start that exhaustive search, and it can be quite daunting:
>> if you are doing this by just code-inspection, it's easy to get
>> it wrong.. I havent quite given up yet, but it may be simpler to have
>> the drivers support some defensive code against bogus skb's in the
>> Tx path (the drivers will know, for sure, what's the min non-paged
>> len they need anyway).
>
> I think it's easier to audit all the header_ops than to add defensive
> code to 500+ drivers.

This issue came up again in a slightly different context. I scanned
the implementations of header_ops. Variable length link layer headers
are quite common. Not necessarily as malleable as ax25, but in
the form of fixed headers with a limited set of optional extensions,
such as ipgre. For this reason, adding ->validate implementations for
each is infeasible, especially for a patch to net.

I think that the right approach is to finally introduce an explicit
dev->min_header_length field, and initialize that at least for
Ethernet and loopback.

I will send that and a related patch.
