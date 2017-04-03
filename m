From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH] soreuseport: use "unsigned int" in __reuseport_alloc()
Date: Mon, 3 Apr 2017 09:56:56 -0400
Message-ID: <CAEfhGix3zu7L0R1siHkF07_aVCxC4ANaV-Lm74SYw1J_BHtJWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:33107 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751998AbdDCN47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 09:56:59 -0400
Received: by mail-qk0-f178.google.com with SMTP id h67so15765597qke.0
        for <netdev@vger.kernel.org>; Mon, 03 Apr 2017 06:56:58 -0700 (PDT)
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com. [209.85.220.179])
        by smtp.gmail.com with ESMTPSA id q8sm9624098qki.58.2017.04.03.06.56.57
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 06:56:57 -0700 (PDT)
Received: by mail-qk0-f179.google.com with SMTP id p22so114596716qka.3
        for <netdev@vger.kernel.org>; Mon, 03 Apr 2017 06:56:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 2, 2017 at 6:18 PM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
> Number of sockets is limited by 16-bit, so 64-bit allocation will never
> happen.
>
> 16-bit ops are the worst code density-wise on x86_64 because of
> additional prefix (66).
So this boils down to a compiled code density vs a
readability/maintainability argument?  I'm not familiar with the 16
bit problem you're referring to, but I'd argue that using the
self-documenting u16 as an input parameter to define the range
expectations is more useful that the micro optimization that this
change may buy you in the assembly of one platform.  Especially given
that this is a rare-use function.

>
> Space savings:
>
>         add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-3 (-3)
>         function                                     old     new   delta
>         reuseport_add_sock                           539     536      -3
>
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
>
>  net/core/sock_reuseport.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> --- a/net/core/sock_reuseport.c
> +++ b/net/core/sock_reuseport.c
> @@ -13,9 +13,9 @@
>
>  static DEFINE_SPINLOCK(reuseport_lock);
>
> -static struct sock_reuseport *__reuseport_alloc(u16 max_socks)
> +static struct sock_reuseport *__reuseport_alloc(unsigned int max_socks)
>  {
> -       size_t size = sizeof(struct sock_reuseport) +
> +       unsigned int size = sizeof(struct sock_reuseport) +
>                       sizeof(struct sock *) * max_socks;
>         struct sock_reuseport *reuse = kzalloc(size, GFP_ATOMIC);
>
