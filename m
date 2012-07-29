From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH] net/tun: fix ioctl() based info leaks
Date: Mon, 30 Jul 2012 01:11:28 +0200
Message-ID: <CAFLxGvwUNxOn3vRLdJeS6hVZ_Oko0_QPZfLWAe+ztCHGdqBFOw@mail.gmail.com>
References: <1343595494-10414-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:39550 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753699Ab2G2XL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2012 19:11:29 -0400
Received: by obbuo13 with SMTP id uo13so8038514obb.19
        for <netdev@vger.kernel.org>; Sun, 29 Jul 2012 16:11:29 -0700 (PDT)
In-Reply-To: <1343595494-10414-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 29, 2012 at 10:58 PM, Mathias Krause <minipli@googlemail.com> wrote:
> The tun module leaks up to 36 bytes of memory by not initializing a
> structure located on the stack that gets copied to user memory by the
> TUNGETIFF and SIOCGIFHWADDR ioctl()s.
>
> Signed-off-by: Mathias Krause <minipli@googlemail.com>
> ---
>  drivers/net/tun.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 987aeef..cadeb94 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1252,9 +1252,12 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>         int vnet_hdr_sz;
>         int ret;
>
> -       if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89)
> +       if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89) {
>                 if (copy_from_user(&ifr, argp, ifreq_len))
>                         return -EFAULT;
> +       } else {
> +               memset(&ifr, 0, sizeof(ifr));
> +       }
>
>         if (cmd == TUNGETFEATURES) {
>                 /* Currently this just means: "what IFF flags are valid?".

The fix makes sense to me.

Beside of the fix, why are you adding braces to if and else?
We don't use braces on single statements.

-- 
Thanks,
//richard
