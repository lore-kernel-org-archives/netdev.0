From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 01/26] compiler: introduce noinline_for_kasan annotation
Date: Fri, 3 Mar 2017 15:51:41 +0100
Message-ID: <CAK8P3a1r9LbZ3f_AcBG6LCmmL9KhzUSUMJuhtVKTkUwYjrexmg@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de> <20170302163834.2273519-2-arnd@arndb.de>
 <7e7a62de-3b79-6044-72fa-4ade418953d1@virtuozzo.com> <CAG_fn=WayMEnBO4pzuxQ5jgn-ii6vrALuOex5Ei1ZhzMR7_tjg@mail.gmail.com>
 <CAK8P3a3+8wxsUntUnOteOv8_p=yBZLk-4Uu-HGM17o9n9OqteQ@mail.gmail.com> <CAG_fn=X3PDDpX_K8Dhk-yCviC87ycRaX4X1d+rJENPZJK_rFmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Networking <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, linux-media@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>
To: Alexander Potapenko <glider@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:35647 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751593AbdCCOwL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 09:52:11 -0500
In-Reply-To: <CAG_fn=X3PDDpX_K8Dhk-yCviC87ycRaX4X1d+rJENPZJK_rFmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 3, 2017 at 3:33 PM, Alexander Potapenko <glider@google.com> wrote:
> On Fri, Mar 3, 2017 at 3:30 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> On Fri, Mar 3, 2017 at 2:55 PM, Alexander Potapenko <glider@google.com> wrote:
>>
>> Would KMSAN also force local variables to be non-overlapping the way that
>> asan-stack=1 and -fsanitize-address-use-after-scope do? As I understood it,
>> KMSAN would add extra code for maintaining the uninit bits, but in an example
>> like this
> The thing is that KMSAN (and other tools that insert heavyweight
> instrumentation) may cause heavy register spilling which will also
> blow up the stack frames.

In that case, I would expect a mostly distinct set of functions to have large
stack frames with KMSAN, compared to the ones that need
noinline_for_kasan. In most cases I patched, the called inline function is
actually trivial, but invoked many times from the same caller.

     Arnd
