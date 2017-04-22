From: Jamie Bainbridge <jbainbri@redhat.com>
Subject: Re: [PATCH 2/2] ipv6: don't deliver packets with zero length to raw sockets
Date: Sat, 22 Apr 2017 22:10:31 +1000
Message-ID: <CAOTh05BdKhTaWJ5OG=BE49TMha4jPjK4rgQ-Xad40W9A0D6HxA@mail.gmail.com>
References: <1492747124-31821-2-git-send-email-jbainbri@redhat.com>
 <20170421100112.GA4824@bistromath.localdomain> <CAOTh05AEQe=QMoStwdXckQ7pPW_ZuDAAj5W78rNqSR-6hNZGSQ@mail.gmail.com>
 <20170421.105332.1898209845543083717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:32898 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1036624AbdDVMKd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 08:10:33 -0400
Received: by mail-it0-f52.google.com with SMTP id 70so3302349ita.0
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 05:10:32 -0700 (PDT)
In-Reply-To: <20170421.105332.1898209845543083717.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 22, 2017 at 12:53 AM, David Miller <davem@davemloft.net> wrote:
> From: Jamie Bainbridge <jbainbri@redhat.com>
> Date: Fri, 21 Apr 2017 21:18:00 +1000
>
>> I cannot see the use in delivering a skb with zero bytes after the
>> network header to a raw socket.
>
> Then it cannot be used to look at zero length UDP packets, which are
> completely legal and used.
>
> So we must deliver it.

Understood, thank you both for the clarification.

That would mean the pattern of select/ioctl/recvfrom is the incorrect
way to code an IPv6 raw socket application. I will let our user know.

How about the other patch in this series? That actually is a valid bug
when skb are paged in a certain way. That patch does not change
behaviour, it just allows ioctl to return the correct result whether
data is linear or paged. Will I resubmit that patch on its own with a
revised commit message?

Jamie
