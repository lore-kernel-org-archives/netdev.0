From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH net] sctp: label accepted/peeled off sockets
Date: Wed, 23 Dec 2015 15:05:24 -0500
Message-ID: <2896613.2hnUueFeeu@sifl>
References: <339eee4a8d20118f871fda8a8b38591a60bea59b.1450895942.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, cluster-devel@redhat.com,
	teigland@redhat.com, Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34014 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932664AbbLWUF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 15:05:26 -0500
Received: by mail-qk0-f177.google.com with SMTP id p187so163765404qkd.1
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 12:05:25 -0800 (PST)
In-Reply-To: <339eee4a8d20118f871fda8a8b38591a60bea59b.1450895942.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, December 23, 2015 04:44:09 PM Marcelo Ricardo Leitner wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> 
> Accepted or peeled off sockets were missing a security label (e.g.
> SELinux) which means that socket was in "unlabeled" state.
> 
> This patch clones the sock's label from the parent sock and resolves the
> issue (similar to AF_BLUETOOTH protocol family).
> 
> Cc: Paul Moore <pmoore@redhat.com>
> Cc: David Teigland <teigland@redhat.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  net/sctp/socket.c | 2 ++
>  1 file changed, 2 insertions(+)

[NOTE: added the LSM and SELinux lists to the CC line as a FYI]

Proper SCTP support is on the SELinux todo list, but in the meantime it looks 
like the patch below should at least ensure that SCTP sockets inherit their 
parent's label which is probably the best we can hope for right now.

Acked-by: Paul Moore <paul@paul-moore.com>

> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index
> 400a14d744834c7a503b338bc68f5f8b5b5dae8e..b67162767b7957b3e9f4f7bf52ab51fc1
> a3499c8 100644 --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -7202,6 +7202,8 @@ void sctp_copy_sock(struct sock *newsk, struct sock
> *sk,
> 
>  	if (newsk->sk_flags & SK_FLAGS_TIMESTAMP)
>  		net_enable_timestamp();
> +
> +	security_sk_clone(sk, newsk);
>  }
> 
>  static inline void sctp_copy_descendant(struct sock *sk_to,

-- 
paul moore
www.paul-moore.com
