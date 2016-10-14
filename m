From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Fri, 14 Oct 2016 12:11:12 +0100
Message-ID: <CAKv+Gu9t2fk2+4QwsDATv11wggQPryobGUGJQHO-G09bYbecGg@mail.gmail.com>
References: <20161010150358.GA514@swordfish> <20161010153050.GA836@swordfish>
 <1476263106.5271.23.camel@sipsolutions.net> <20161012141245.GA436@swordfish>
 <1476282127.5271.30.camel@sipsolutions.net> <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
 <1476338524.4904.1.camel@sipsolutions.net> <20161013134252.GA583@swordfish>
 <1476366354.4904.31.camel@sipsolutions.net> <CALCETrW8imkGTtR9-mFB=e=Gdr1QXVuhXN3GRs2B6wbmPaaGhA@mail.gmail.com>
 <1476429916.4382.12.camel@sipsolutions.net> <1476433699.31114.6.camel@sipsolutions.net>
 <CAKv+Gu8hTy8U7FcA58P1YWt2rHU09xP9v1UU0KcnD4uuaK8How@mail.gmail.com>
 <CAKv+Gu_v+4D_7EvRkrSrStheuP1L-oPh=o7Ub+NU7-wgLYks4w@mail.gmail.com>
 <1476434561.31114.7.camel@sipsolutions.net> <CAKv+Gu896xme5sd5i8hs7tA=Xt=qQKCiAx7fQg1ZECn50NttbQ@mail.gmail.com>
 <1476435303.31114.14.camel@sipsolutions.net> <CAKv+Gu9KObA61fEYxr1FFj_3SKNS2RUbqZo01yfnm9Bf0AncwA@mail.gmail.com>
 <1476436248.31114.21.camel@sipsolutions.net> <CAKv+Gu-Y6wuMGuRgrHRGCvAM9qZjvufs=7VWL8hAUKFSF=tZWg@mail.gmail.com>
 <1476437149.31114.27.camel@sipsolutions.net> <CAKv+Gu_p7neD-ttCBBA6p7VSkQt8mvfhS9cdcLftdkXNtAAFnQ@mail.gmail.com>
 <1476439212.31114.37.camel@sipsolutions.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476439212.31114.37.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14 October 2016 at 11:00, Johannes Berg <johannes@sipsolutions.net> wrote:
>
>> So why is the performance hit acceptable for ESP but not for WPA? We
>> could easily implement the same thing, i.e.,
>> kmalloc(GFP_ATOMIC)/kfree the aead_req struct rather than allocate it
>> on the stack
>
> Yeah, maybe we should. It's likely a much bigger allocation, but I
> don't actually know if that affects speed.
>
> In most cases where you want high performance we never hit this anyway
> since we'll have hardware crypto. I know for our (Intel's) devices we
> normally never hit these code paths.
>
> But on the other hand, you also did your changes for a reason, and the
> only reason I can see of that is performance. So you'd be the one with
> most "skin in the game", I guess?
>

Well, what sucks here is that the accelerated driver I implemented for
arm64 does not actually need this, as long as we take aad[] off the
stack. And note that the API was changed since my patch, to add aad[]
to the scatterlist: prior to this change, it used
aead_request_set_assoc() to set the associated data separately.
