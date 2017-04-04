From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] soreuseport: use "unsigned int" in __reuseport_alloc()
Date: Tue, 4 Apr 2017 14:36:02 +0300
Message-ID: <CACVxJT8OM1CafJuvM3uYvVANC=JTB9aZSAVqFP9t1sY4pa7xcw@mail.gmail.com>
References: <CAEfhGix3zu7L0R1siHkF07_aVCxC4ANaV-Lm74SYw1J_BHtJWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34190 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752881AbdDDLgD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 07:36:03 -0400
Received: by mail-qk0-f177.google.com with SMTP id d10so138844978qke.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 04:36:03 -0700 (PDT)
In-Reply-To: <CAEfhGix3zu7L0R1siHkF07_aVCxC4ANaV-Lm74SYw1J_BHtJWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 3, 2017 at 4:56 PM, Craig Gallek <kraigatgoog@gmail.com> wrote:
> On Sun, Apr 2, 2017 at 6:18 PM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>> Number of sockets is limited by 16-bit, so 64-bit allocation will never
>> happen.
>>
>> 16-bit ops are the worst code density-wise on x86_64 because of
>> additional prefix (66).
> So this boils down to a compiled code density vs a
> readability/maintainability argument?  I'm not familiar with the 16
> bit problem you're referring to, but I'd argue that using the
> self-documenting u16 as an input parameter to define the range
> expectations is more useful that the micro optimization that this
> change may buy you in the assembly of one platform.  Especially given
> that this is a rare-use function.

It's not a problem as in "create trouble".
16-bit operations are the worst on x86_64: they require additional prefix,
compiler often has to extend it to 32-bit to do anything useful
(MOVZX = 1 cycle, 3 bytes) because of cast-everything-to-int
behaviour enabled by the language.
