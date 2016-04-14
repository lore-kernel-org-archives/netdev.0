From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCHv3 net-next 4/6] sctp: add the sctp_diag.c file
Date: Thu, 14 Apr 2016 14:41:59 +0200
Message-ID: <87r3e8s6p4.fsf@beetle.home>
References: <cover.1460618169.git.lucien.xin@gmail.com> <cd6bf9c2696f125a74491e1f82b77a30bb1005dd.1460618169.git.lucien.xin@gmail.com> <d3fc80db41935f6b22d9fffc5854de63fb842899.1460618169.git.lucien.xin@gmail.com> <c771f8320e007cd5d1801a820f0cca8f7ed7235c.1460618169.git.lucien.xin@gmail.com> <c48759e983ae5f9cefdd1805025abb7f57299886.1460618169.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net, eric.dumazet@gmail.com
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754594AbcDNMmF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2016 08:42:05 -0400
In-reply-to: <c48759e983ae5f9cefdd1805025abb7f57299886.1460618169.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Xin,

On Thu, Apr 14, 2016 at 09:35 AM CEST, Xin Long <lucien.xin@gmail.com> wrote:
> This one will implement all the interface of inet_diag, inet_diag_handler.
> which includes sctp_diag_dump, sctp_diag_dump_one and sctp_diag_get_info.
>
> It will work as a module, and register inet_diag_handler when loading.
>
> v2->v3:
> - fix the mistake in inet_assoc_attr_size().
>
> - change inet_diag_msg_laddrs_fill() name to inet_diag_msg_sctpladdrs_fill.
>
> - change inet_diag_msg_paddrs_fill() name to inet_diag_msg_sctpaddrs_fill.
>
> - add inet_diag_msg_sctpinfo_fill() to make asoc/ep fill code clearer.
>
> - add inet_diag_msg_sctpasoc_fill() to make asoc fill code clearer.
>
> - merge inet_asoc_diag_fill() and inet_ep_diag_fill() to
>   inet_sctp_diag_fill().
>
> - call sctp_diag_get_info() directly, instead by handler, cause the caller
>   is in the same file with it.
>
> - call lock_sock in sctp_tsp_dump_one() to make sure we call get sctp info
>   safely.
>
> - after lock_sock(sk), we should check sk != assoc->base.sk.
>
> - change mem[SK_MEMINFO_WMEM_ALLOC] to asoc->sndbuf_used for asoc dump when
>   asoc->ep->sndbuf_policy is set. don't use INET_DIAG_MEMINFO attr any more.
>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---

[...]

> diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
> new file mode 100644
> index 0000000..98ecd16
> --- /dev/null
> +++ b/net/sctp/sctp_diag.c
> @@ -0,0 +1,497 @@

[...]

> +#define EXPIRES_IN_MS(tmo)  DIV_ROUND_UP((tmo - jiffies) * 1000, HZ)
> +	r->idiag_expires =
> +		EXPIRES_IN_MS(asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX]);
> +#undef EXPIRES_IN_MS

How about using jiffies_to_msecs() here? It's already being used
elsewhere in net/sctp.

AFAICT EXPIRES_IN_MS macro comes from net/ipv4/inet_diag.c and dates
back to before jiffies_to_msecs() has been introduced. Perhaps that's
why it's still used in inet_diag.c. But this is new code.

Thanks,
Jakub
