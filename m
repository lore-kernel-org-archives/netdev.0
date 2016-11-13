From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Source address fib invalidation on IPv6
Date: Sun, 13 Nov 2016 01:43:08 +0100
Message-ID: <CAHmME9pMzcwjveOoa08-fVCnZTkaoMz8y9DEc7f6b-4PeWu4xQ@mail.gmail.com>
References: <CAHmME9qi7_C7c=wsZg=EwBg3jzFzVmW1eiFGGXgcX8fCcOOZcA@mail.gmail.com>
 <31e050e2-0499-a77e-f698-86e58ad2fa6b@cumulusnetworks.com>
 <CAHmME9o_AM1Lms6CJSpbjfAgcyGuRx8yqwSaNWEbSnY7gGnt6w@mail.gmail.com>
 <CAHmME9oeAuBQJguTFivYsYw4fMoc4+sgxcdS4MArN474m7NjTQ@mail.gmail.com>
 <0dbf5deb-bffb-4878-a268-1adb17c47676@cumulusnetworks.com> <CAHmME9owJNvMfF9jHGW7i_jPMaxwPhxQE5W6cxjw14nL0HK0eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        WireGuard mailing list <wireguard@lists.zx2c4.com>,
        LKML <linux-kernel@vger.kernel.org>,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:56677 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752084AbcKMAnP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Nov 2016 19:43:15 -0500
In-Reply-To: <CAHmME9owJNvMfF9jHGW7i_jPMaxwPhxQE5W6cxjw14nL0HK0eQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 12, 2016 at 8:08 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>> Gotcha. I don't see any checks that the saddr is valid similar to what IPv4 does.
>>
>> I think the right place to add a check is in ip6_dst_lookup_tail():
>>     if (!ipv6_addr_any(&fl6->saddr)) {
>>         // saddr is valid for L3 domain
>>     }
>
> Right. It should probably do the check here, and return
> ERR_PTR(-EINVAL), the same as the v4 version, so that ret codes can be
> checked consistently.
>
> Thanks for looking into this. If you're backed up and would like me to
> submit a patch, just let me know, and I'll give it my best shot.

In perusing through the v6 FIB code, I don't even see an analog of
__ip_dev_find... Hm?
