From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH] mac80211: aes_ccm: move struct aead_req off the stack
Date: Fri, 14 Oct 2016 14:19:21 +0100
Message-ID: <CAKv+Gu81RYq1aZUQ2Aru3Vev4LGgb1zFwWz8gepE0tQEhQi9Uw@mail.gmail.com>
References: <1476450540-1760-1-git-send-email-ard.biesheuvel@linaro.org>
 <1476450635.31114.42.camel@sipsolutions.net> <CAKv+Gu_eS-C84rH_MLYy--ivC0a99wwJvNDLhETfrBkYXW-XpA@mail.gmail.com>
 <1476450941.31114.45.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Jouni Malinen <j@w1.fi>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476450941.31114.45.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14 October 2016 at 14:15, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Fri, 2016-10-14 at 14:13 +0100, Ard Biesheuvel wrote:
>>
>> > But if we allocate things anyway, is it worth expending per-CPU
>> > buffers on these?
>>
>> Ehmm, maybe not. I could spin a v2 that allocates a bigger buffer,
>> and copies aad[] into it as well
>
> Copies in/out, I guess. Also there's B_0/J_0 for CCM/GCM, and the
> 'zero' thing that GMAC has.
>

Is the aad[] actually reused? I would assume it only affects the mac
on encryption, and the verification on decryption but I don't think we
actually need it back from the crypto routines.

>> That does not help the other algos though
>
> What do you mean?
>

Exactly what you said above :-) My patch only touches CCM but as you said,

"""
'Also there's B_0/J_0 for CCM/GCM, and the 'zero' thing that GMAC has.
"""
