From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] netlink: do not proceed if dump's start() errs
Date: Wed, 27 Sep 2017 14:50:55 +0200
Message-ID: <CAHmME9pUWenvkMCNkAHa6K71UDdETvriMr52sKPL38q19M3RVw@mail.gmail.com>
References: <20170927123915.5779-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>, johannes.berg@intel.com,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927123915.5779-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 2:39 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> -       if (cb->start)
> -               cb->start(cb);
> +       if (cb->start) {
> +               ret = cb->start(cb);
> +               if (ret)

I need to sock_put(sk); before returning. I'll fix this for v2, but
will for additional comments in case anybody has some.

> +                       return ret;
> +       }
>
>         ret = netlink_dump(sk);
>         sock_put(sk);
