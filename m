From: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] mac80211: aes_ccm: move struct aead_req off the stack
Date: Fri, 14 Oct 2016 14:13:08 +0100
Message-ID: <CAKv+Gu_eS-C84rH_MLYy--ivC0a99wwJvNDLhETfrBkYXW-XpA@mail.gmail.com>
References: <1476450540-1760-1-git-send-email-ard.biesheuvel@linaro.org> <1476450635.31114.42.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Jouni Malinen <j@w1.fi>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476450635.31114.42.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 14 October 2016 at 14:10, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
>
>> So use kzalloc
>
> Do we really need kzalloc()? We have things on the stack right now, and
> don't initialize, so surely we don't really need to zero things?
>
>> This only addresses one half of the problem. The other problem, i.e.,
>> the fact that the aad[] array lives on the stack of the caller, is
>> handled adequately imo by the change proposed by Johannes.
>
> But if we allocate things anyway, is it worth expending per-CPU buffers
> on these?
>

Ehmm, maybe not. I could spin a v2 that allocates a bigger buffer, and
copies aad[] into it as well
That does not help the other algos though
