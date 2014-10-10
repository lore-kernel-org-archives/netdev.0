From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH][net-next] net: filter: replace sk_run_filter with
 __bpf_prog_run in comments
Date: Thu, 9 Oct 2014 21:17:51 -0700
Message-ID: <CAADnVQ+7jgin=GtF3gdf2vOk-msA7smee8Gq+s7kaRjBdOP8wg@mail.gmail.com>
References: <1412912231-1004-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:35994 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbaJJERw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 00:17:52 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so3340737qgf.7
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 21:17:52 -0700 (PDT)
In-Reply-To: <1412912231-1004-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 9, 2014 at 8:37 PM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> sk_run_filter has been renamed as __bpf_prog_run, so replace them in comments
>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/core/filter.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index fcd3f67..9324601 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -51,9 +51,9 @@
>   *     @skb: buffer to filter
>   *
>   * Run the filter code and then cut skb->data to correct size returned by
> - * sk_run_filter. If pkt_len is 0 we toss packet. If skb->len is smaller
> + * __bpf_prog_run. If pkt_len is 0 we toss packet. If skb->len is smaller
>   * than pkt_len we keep whole skb->data. This is the socket level
> - * wrapper to sk_run_filter. It returns 0 if the packet should
> + * wrapper to __bpf_prog_run. It returns 0 if the packet should
>   * be accepted or -EPERM if the packet should be tossed.

not quite. I think in both of the above lines it's better to replace
sk_run_filter with SK_RUN_FILTER

>   *
>   */
> @@ -567,10 +567,10 @@ err:
>  /* Security:
>   *
>   * A BPF program is able to use 16 cells of memory to store intermediate
> - * values (check u32 mem[BPF_MEMWORDS] in sk_run_filter()).
> + * values (check u32 mem[BPF_MEMWORDS] in __bpf_prog_run()).

this just wrong. Better to remove this line.

>   *
>   * As we dont want to clear mem[] array for each packet going through
> - * sk_run_filter(), we check that filter loaded by user never try to read
> + * __bpf_prog_run(), we check that filter loaded by user never try to read

here the change is fine.
