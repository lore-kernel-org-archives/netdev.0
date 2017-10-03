From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH iproute2] iproute: build more easily on Android
Date: Wed, 4 Oct 2017 01:35:32 +0900
Message-ID: <CAKD1Yr1g+GLy-DZT5uR8oOXPcDOYRBRRN80Jz-A-VKOvazaVUw@mail.gmail.com>
References: <20171002170337.42235-1-lorenzo@google.com> <20171002103611.17ccb01f@xeon-e3>
 <CAJgzZor7VMuTWgRUvVp_q=DHEm5bdgHNWxBJ3wG+X9GWTEwB7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: enh <enh@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:57000 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751689AbdJCQfy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 12:35:54 -0400
Received: by mail-qt0-f179.google.com with SMTP id e19so10153251qta.13
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 09:35:54 -0700 (PDT)
In-Reply-To: <CAJgzZor7VMuTWgRUvVp_q=DHEm5bdgHNWxBJ3wG+X9GWTEwB7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 3, 2017 at 5:23 AM, enh <enh@google.com> wrote:
>> Rather than moving everything, why not make kernel headers directory
>> configurable as part of the configure script setup process.
>
> the problem is that C libraries with their our own uapi headers still
> need your app-specific headers. to build iproute2 we need to put
> iproute2's include/ on our include path, but then the fact that your
> different uapi headers are *under* that directory causes the conflict.

Right - when building iproute2 we must have .../iproute2/include in
the include paths.

So when, say, ip/link_iptnl.c does #include <linux/in.h>, that file is
in two places in the path - the C library includes and the iproute
includes, and those two files conflict with each other.

There's no way to tell the compiler "use external/iproute2/include but
not external/iproute2/include/linux". But if the iproute2 files are in
uapi/ , then a simple #include <linux/in.h> won't find the UAPI copy
and the files won't conflict.
