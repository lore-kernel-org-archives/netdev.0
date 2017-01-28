From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 1/4] mlx5: Make building eswitch configurable
Date: Sat, 28 Jan 2017 13:20:26 +0200
Message-ID: <CALzJLG_abLhT7wcrtB97KzurJ2-=OZv11cELjoRW79cOeyjxgw@mail.gmail.com>
References: <20170126233241.2268449-1-tom@herbertland.com> <20170126233241.2268449-2-tom@herbertland.com>
 <CAJ3xEMhaQ4zsBxkWzs8qCv5KT-gAmdD9dNkSS+KDwB+VGw5SEw@mail.gmail.com>
 <CALzJLG_v2HxsdPdX5H=T51RGmaMMnXVxzihuPN66a9RxDadEcw@mail.gmail.com>
 <CALx6S34K-N7TWtEG0cCgq-zAXqqfNp9zp1JtR8bLvD=F90A2pg@mail.gmail.com>
 <CALzJLG9YXBzXAOrtth7SX8n3S5cN3ZSmKax4FOGiTr7SY8gobg@mail.gmail.com>
 <CALx6S375OVvSi5QLLCpsGc84iE3cJ3VH5Rm6sg8OJgDR=nqXfA@mail.gmail.com>
 <CALzJLG_WCiTei7CDoUCzM241gt0bSKqjGJ61ke2XbbQTOjZBkQ@mail.gmail.com>
 <CALx6S35-ecvO0k6-yqdLpO6mXA4Y6mycMD3HqHPCaUtMZd8GYA@mail.gmail.com>
 <CALzJLG-U2uLB2uqeVT1viP87oxDEp1XUymu-zVRhe9yGrBEc+w@mail.gmail.com> <588BD66E.2050201@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34362 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750858AbdA1LVY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 06:21:24 -0500
Received: by mail-qt0-f195.google.com with SMTP id w20so16742801qtb.1
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 03:20:47 -0800 (PST)
In-Reply-To: <588BD66E.2050201@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 28, 2017 at 1:23 AM, Alexei Starovoitov <ast@fb.com> wrote:
> On 1/27/17 1:15 PM, Saeed Mahameed wrote:
>>
>> It is only mandatory for configurations that needs eswitch, where the
>> driver has no way to know about them, for a good old bare metal box,
>> eswitch is not needed.
>>
>> we can do some work to strip the l2 table logic - needed for PFs to
>> work on multi-host - out of eswitch but again that would further
>> complicate the driver code since eswitch will still need to update l2
>> tables for VFs.
>
>
> Saeed,
> for multi-host setups every host in that multi-host doesn't
> actually see the eswitch, no? Otherwise broken driver on one machine
> can affect the other hosts in the same bundle? Please double check,

each host (PF) has its own eswitch, and each eswitch lives in its own
"steering-space"
 and it can't affect others.

> since this is absolutely critical HW requirement.
>

The only shared HW resources between hosts (PFs) is the simple l2 table,
and the only thing a host can ask from the l2 talbe (FW) is: "forward
UC MAC to me", and it is the responsibility of the the driver eswitch
to do so.

the l2 table is created and managed by FW, SW eswitch can only request
from FW, and the FW is trusted.
