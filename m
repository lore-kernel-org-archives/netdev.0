From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Fri, 14 Oct 2016 11:10:48 +0200
Message-ID: <1476436248.31114.21.camel@sipsolutions.net>
References: <20161010150358.GA514@swordfish>
         <20161010153050.GA836@swordfish>
         <1476263106.5271.23.camel@sipsolutions.net>
         <20161012141245.GA436@swordfish>
         <1476282127.5271.30.camel@sipsolutions.net>
         <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
         <1476338524.4904.1.camel@sipsolutions.net> <20161013134252.GA583@swordfish>
         <1476366354.4904.31.camel@sipsolutions.net>
         <CALCETrW8imkGTtR9-mFB=e=Gdr1QXVuhXN3GRs2B6wbmPaaGhA@mail.gmail.com>
         <1476429916.4382.12.camel@sipsolutions.net>
         <1476433699.31114.6.camel@sipsolutions.net>
         <CAKv+Gu8hTy8U7FcA58P1YWt2rHU09xP9v1UU0KcnD4uuaK8How@mail.gmail.com>
         <CAKv+Gu_v+4D_7EvRkrSrStheuP1L-oPh=o7Ub+NU7-wgLYks4w@mail.gmail.com>
         <1476434561.31114.7.camel@sipsolutions.net>
         <CAKv+Gu896xme5sd5i8hs7tA=Xt=qQKCiAx7fQg1ZECn50NttbQ@mail.gmail.com>
         <1476435303.31114.14.camel@sipsolutions.net>
         <CAKv+Gu9KObA61fEYxr1FFj_3SKNS2RUbqZo01yfnm9Bf0AncwA@mail.gmail.com>
         (sfid-20161014_110501_838823_6646CA89)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
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
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKv+Gu9KObA61fEYxr1FFj_3SKNS2RUbqZo01yfnm9Bf0AncwA@mail.gmail.com> (sfid-20161014_110501_838823_6646CA89)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-10-14 at 10:05 +0100, Ard Biesheuvel wrote:
> 
> Indeed. And the decrypt path does the same for auth_tag[].

Hadn't gotten that far, due to the BUG_ON() in CONFIG_DEBUG_SG in the
encrypt path :)

> But that still means there are two separate problems here, one which
> affects the WPA code, and one that only affects the generic CCM
> chaining mode (but not the accelerated arm64 implementation)

Yes. The generic CCM chaining still doesn't typically have a request on
the stack though. In fact, ESP (net/ipv4/esp4.c) for example will do
temporary allocations with kmalloc for every frame, it seems.

> Unsurprisingly, I would strongly prefer those to be fixed properly
> rather than backing out my patch, but I'm happy to help out whichever
> solution we reach consensus on.

Yeah, obviously, it would be good to use the accelerated versions after
all.

> I will check whether this removes the issue when not using
> crypto/ccm.ko

Ok. I think we can probably live with having those 48 bytes in per-CPU
buffers, but I suppose we don't really want to have ~500.

johannes
