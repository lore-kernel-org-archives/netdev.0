From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2/5] gtp: Improve another size determination in ipv4_pdp_add()
Date: Thu, 26 Jan 2017 16:11:08 +0300
Message-ID: <CACVxJT9k-O3A_Uj9=qCX_s8jV=kcZz7c0THNxGjO74mapBPZoQ@mail.gmail.com>
References: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net> <91f31650-3052-507c-8006-96874107f981@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Harald Welte <laforge@gnumonks.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Pablo Neira <pablo@netfilter.org>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <91f31650-3052-507c-8006-96874107f981@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 26, 2017 at 1:18 PM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:

> -       pctx = kmalloc(sizeof(struct pdp_ctx), GFP_KERNEL);
> +       pctx = kmalloc(sizeof(*pctx), GFP_KERNEL);

The rule about "sizeof(*p)" style of allocation is bogus and should be
abolished.

Rationale says that

    > The alternative form where struct name is spelled out hurts readability

In terms of line length, yes, "sizeof(*p)" wins most of the time.
However, the former variant clearly show the type of data, so you don't need
to look it up and makes it readily available to follow with tags or equivalent.

    > and introduces an opportunity for a bug when the pointer variable type
    > is changed but the corresponding sizeof that is passed to a memory
    > allocator is not.

The correct way to prevent this kind of mistake is to not return "void
*" pointer
(at least most of the uses use typed allocation)

    #define lmalloc(T, gfp) (T*)_kmalloc(sizeof(T), (gfp))

Bacause of a cast changing type of pointer will be noticed,
