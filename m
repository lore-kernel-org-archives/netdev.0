From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 07:06:26 -0400
Message-ID: <484dedaf-4e81-9a5a-ffb8-2c65b373c3a0@mojatatu.com>
References: <20160928090357.GT1876@uranus.lan>
 <caef7649-9d25-6429-eeab-96c027d6cbc2@mojatatu.com>
 <20160928101726.GU1876@uranus.lan>
 <8293413c-a81d-f7ff-24f0-8f58ce877116@mojatatu.com>
 <20160928105147.GV1876@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33324 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752630AbcI1LG3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 07:06:29 -0400
Received: by mail-io0-f196.google.com with SMTP id r145so2870894ior.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 04:06:29 -0700 (PDT)
In-Reply-To: <20160928105147.GV1876@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-28 06:51 AM, Cyrill Gorcunov wrote:
> On Wed, Sep 28, 2016 at 06:43:01AM -0400, Jamal Hadi Salim wrote:

[..]
>> I dont know how compilation will fail but you may be right with note:
>> that is not how pads have been used in the past. They are supposed to
>> cosmetic annotation which indicates "here's a hole; use it in the
>> future if you are looking to add something". And someone in the
>> future can claim them. I am not sure if MBZ philosophy applies.
>
> This structure is uapi, so anyone has complete rights to reference
> @pad in the userspace programs. Sure it would be more clear to remove
> the @pad completely, but if we choose so I think it's better to do
> on top instead and then if someone complain we can easily revert
> the single trivial commit instead of this big patch.

I am conflicted.
A field labelled "pad" does not appear to be valid as "UAPI". It is
a cosmetic indicator. If you did sizeof() with or without it being
present the value doesnt change.
BTW: There is at least one major structure in inet diag has a hole
today and doesnt have a padding indicator.

> If protocol goes over u8 then complete inet_diag_req_v2 structure will
> have to be reworked becaue @sdiag_protocol is u8 as well. IOW, once
> someone liftup IPPROTO_MAX > 255, he will notice the problem immediately
> because diag for such module simply stop working properly.
>

ok.

cheers,
jamal
