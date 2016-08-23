From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: fix overrun in sctp_diag_dump_one()
Date: Wed, 24 Aug 2016 00:23:05 +0800
Message-ID: <CADvbK_fn7jAo7ZeVwa58L54uZoE1sj34Ty473RutOUQ8sfVmQA@mail.gmail.com>
References: <1471966852-6218-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36810 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbcHWQf4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 12:35:56 -0400
In-Reply-To: <1471966852-6218-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 23, 2016 at 11:40 PM, Lance Richardson <lrichard@redhat.com> wrote:
> The function sctp_diag_dump_one() currently performs a memcpy()
> of 64 bytes from a 16 byte field into another 16 byte field. Fix
> by using correct size, use sizeof to obtain correct size instead
> of using a hard-coded constant.
>
> Fixes: 8f840e47f190 ("sctp: add the sctp_diag.c file")
> Signed-off-by: Lance Richardson <lrichard@redhat.com>
> ---
>  net/sctp/sctp_diag.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
> index bb69153..f3508aa 100644
> --- a/net/sctp/sctp_diag.c
> +++ b/net/sctp/sctp_diag.c
> @@ -424,11 +424,13 @@ static int sctp_diag_dump_one(struct sk_buff *in_skb,
>                 paddr.v4.sin_family = AF_INET;
>         } else {
>                 laddr.v6.sin6_port = req->id.idiag_sport;
> -               memcpy(&laddr.v6.sin6_addr, req->id.idiag_src, 64);
> +               memcpy(&laddr.v6.sin6_addr, req->id.idiag_src,
> +                      sizeof(laddr.v6.sin6_addr));
>                 laddr.v6.sin6_family = AF_INET6;
>
>                 paddr.v6.sin6_port = req->id.idiag_dport;
> -               memcpy(&paddr.v6.sin6_addr, req->id.idiag_dst, 64);
> +               memcpy(&paddr.v6.sin6_addr, req->id.idiag_dst,
> +                      sizeof(paddr.v6.sin6_addr));
>                 paddr.v6.sin6_family = AF_INET6;
>         }
>
> --
> 2.5.5
>

Reviewed-by: Xin Long <lucien.xin@gmail.com>
