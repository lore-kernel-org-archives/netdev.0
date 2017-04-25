From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] macsec: avoid heap overflow in skb_to_sgvec
Date: Tue, 25 Apr 2017 17:08:28 +0200
Message-ID: <CAHmME9ovUDJRDA+Td4Y0bfQZEG5pZQo1JC0nYDVqWMOdxAe5kQ@mail.gmail.com>
References: <20170421211448.16995-1-Jason@zx2c4.com> <20170425145340.GA25241@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>, stable@vger.kernel.org,
        security@kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170425145340.GA25241@bistromath.localdomain>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sabrina,

On Tue, Apr 25, 2017 at 4:53 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> Ugh, good catch :/
>
> AFAICT this patch doesn't really help, because NETIF_F_FRAGLIST
> doesn't get tested in paths that can lead to triggering this.

You're right. This fixes the xmit() path, but not the receive path,
which appears to take skbs directly from the upper device.

> I'll post a patch to allocate a properly-sized sg array.

I just posted this series, which should fix things in a robust way:

https://patchwork.ozlabs.org/patch/754861/

If you want to handle fraglists, it might be a decent idea to allocate
things of the proper size, I guess. It's a good opportunity to call
skb_cow_data, which you need to do anyway when modifying skbs, I
think.

Jason
