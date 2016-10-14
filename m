From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Fri, 14 Oct 2016 10:05:00 +0100
Message-ID: <CAKv+Gu9KObA61fEYxr1FFj_3SKNS2RUbqZo01yfnm9Bf0AncwA@mail.gmail.com>
References: <20161010150358.GA514@swordfish> <20161010153050.GA836@swordfish>
 <1476263106.5271.23.camel@sipsolutions.net> <20161012141245.GA436@swordfish>
 <1476282127.5271.30.camel@sipsolutions.net> <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
 <1476338524.4904.1.camel@sipsolutions.net> <20161013134252.GA583@swordfish>
 <1476366354.4904.31.camel@sipsolutions.net> <CALCETrW8imkGTtR9-mFB=e=Gdr1QXVuhXN3GRs2B6wbmPaaGhA@mail.gmail.com>
 <1476429916.4382.12.camel@sipsolutions.net> <1476433699.31114.6.camel@sipsolutions.net>
 <CAKv+Gu8hTy8U7FcA58P1YWt2rHU09xP9v1UU0KcnD4uuaK8How@mail.gmail.com>
 <CAKv+Gu_v+4D_7EvRkrSrStheuP1L-oPh=o7Ub+NU7-wgLYks4w@mail.gmail.com>
 <1476434561.31114.7.camel@sipsolutions.net> <CAKv+Gu896xme5sd5i8hs7tA=Xt=qQKCiAx7fQg1ZECn50NttbQ@mail.gmail.com>
 <1476435303.31114.14.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Jouni Malinen <j@w1.fi>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34734 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750889AbcJNJFB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 05:05:01 -0400
Received: by mail-io0-f176.google.com with SMTP id r30so114489837ioi.1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 02:05:01 -0700 (PDT)
In-Reply-To: <1476435303.31114.14.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 October 2016 at 09:55, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Fri, 2016-10-14 at 09:47 +0100, Ard Biesheuvel wrote:
>>
>> Do you have a reference for the sg_set_buf() call on odata?
>> crypto/ccm.c does not seem to have it (afaict),
>
> It's indirect - crypto_ccm_encrypt() calls crypto_ccm_init_crypt()
> which does it.
>

Indeed. And the decrypt path does the same for auth_tag[].

But that still means there are two separate problems here, one which
affects the WPA code, and one that only affects the generic CCM
chaining mode (but not the accelerated arm64 implementation)

Unsurprisingly, I would strongly prefer those to be fixed properly
rather than backing out my patch, but I'm happy to help out whichever
solution we reach consensus on.

>> and the same problem
>> does not exist in the accelerated arm64 implementation. In the mean
>> time, I will try and see if we can move aad[] off the stack in the
>> WPA code.
>
> I had that with per-CPU buffers, just sent the patch upthread.
>

I will check whether this removes the issue when not using crypto/ccm.ko
