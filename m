From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: ptp: mark filter as __initdata
Date: Sat, 10 May 2014 15:22:38 -0700
Message-ID: <CAADnVQJo-P7FTXUNXN58Dt0LK12pLjK04O7aq7LB1c-WPPdh_w@mail.gmail.com>
References: <1399753408-14861-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:52253 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbaEJWWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 18:22:39 -0400
Received: by mail-qc0-f175.google.com with SMTP id w7so6112581qcr.6
        for <netdev@vger.kernel.org>; Sat, 10 May 2014 15:22:38 -0700 (PDT)
In-Reply-To: <1399753408-14861-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 10, 2014 at 1:23 PM, Mathias Krause <minipli@googlemail.com> wrote:
> sk_unattached_filter_create() will copy the filter's instructions so we
> don't need to have the master copy hanging around after initialization.
>
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Nice! Every bit counts.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

> ---
>  net/core/ptp_classifier.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/ptp_classifier.c b/net/core/ptp_classifier.c
> index eaba0f68f8..37d86157b7 100644
> --- a/net/core/ptp_classifier.c
> +++ b/net/core/ptp_classifier.c
> @@ -88,7 +88,7 @@ EXPORT_SYMBOL_GPL(ptp_classify_raw);
>
>  void __init ptp_classifier_init(void)
>  {
> -       static struct sock_filter ptp_filter[] = {
> +       static struct sock_filter ptp_filter[] __initdata = {
>                 { 0x28,  0,  0, 0x0000000c },
>                 { 0x15,  0, 12, 0x00000800 },
>                 { 0x30,  0,  0, 0x00000017 },
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
