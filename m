From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 5/5] xdp: get tracepoints xdp_exception and xdp_redirect
 in sync
Date: Tue, 22 Aug 2017 23:30:21 +0200
Message-ID: <599CA26D.7060003@iogearbox.net>
References: <150343479290.31091.8019008896152616977.stgit@firesoul> <150343485998.31091.4036615069956176401.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33121 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751711AbdHVVaX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:30:23 -0400
In-Reply-To: <150343485998.31091.4036615069956176401.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2017 10:47 PM, Jesper Dangaard Brouer wrote:
> Remove the net_device string name from the xdp_exception tracepoint,
> like the xdp_redirect tracepoint.
>
> Align the TP_STRUCT to have common entries between these two
> tracepoint.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>   include/trace/events/xdp.h |   24 ++++++++++++------------
>   1 file changed, 12 insertions(+), 12 deletions(-)
>
> diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
> index 7511bed80558..6495b0d9d5c7 100644
> --- a/include/trace/events/xdp.h
> +++ b/include/trace/events/xdp.h
> @@ -31,22 +31,22 @@ TRACE_EVENT(xdp_exception,
>   	TP_ARGS(dev, xdp, act),
>
>   	TP_STRUCT__entry(
> -		__string(name, dev->name)
>   		__array(u8, prog_tag, 8)
>   		__field(u32, act)
> +		__field(int, ifindex)
>   	),
>
>   	TP_fast_assign(
>   		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(xdp->tag));
>   		memcpy(__entry->prog_tag, xdp->tag, sizeof(xdp->tag));
> -		__assign_str(name, dev->name);
> -		__entry->act = act;
> +		__entry->act		= act;
> +		__entry->ifindex	= dev->ifindex;
>   	),
>
[...]
>   TRACE_EVENT(xdp_redirect,
> @@ -57,26 +57,26 @@ TRACE_EVENT(xdp_redirect,
>   	TP_ARGS(from_index, to_index, xdp, act, err),
>
>   	TP_STRUCT__entry(
> -		__field(int, from_index)
> -		__field(int, to_index)
>   		__array(u8, prog_tag, 8)
>   		__field(u32, act)
> +		__field(int, from_index)
> +		__field(int, to_index)
>   		__field(int, err)
>   	),
>
>   	TP_fast_assign(
>   		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(xdp->tag));
>   		memcpy(__entry->prog_tag, xdp->tag, sizeof(xdp->tag));
> +		__entry->act		= act;
>   		__entry->from_index	= from_index;
>   		__entry->to_index	= to_index;
> -		__entry->act = act;

If you already get them in sync, could you also make it consistent
that for both tracepoints in TP_ARGS() we use either ifindex
directly or device pointer and extract it from TP_fast_assign().
Right now, it's mixed.
