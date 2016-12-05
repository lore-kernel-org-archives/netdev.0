From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: ping: check minimum size on ICMP header length
Date: Mon, 5 Dec 2016 12:35:47 +0900
Message-ID: <CAKD1Yr30VVN=fmE8GpQ-hUv1bGVC=OxATpRpspruD2CPhKOnYQ@mail.gmail.com>
References: <20161203005853.GA117599@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Min Chong <mchong@google.com>, Qidan He <i@flanker017.me>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        lkml <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161203005853.GA117599@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 3, 2016 at 9:58 AM, Kees Cook <keescook@chromium.org> wrote:
> -       if (len > 0xFFFF)
> +       if (len > 0xFFFF || len < icmph_len)
>                 return -EMSGSIZE;

EMSGSIZE usually means the message is too long. Maybe use EINVAL?
That's what the code will return if the passed-in ICMP header is
invalid (e.g., is not an echo request).
