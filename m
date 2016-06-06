From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] netlabel: add address family checks to netlbl_{sock, req}_delattr()
Date: Mon, 6 Jun 2016 15:37:56 -0400
Message-ID: <CAGH-Kgsftoux6aaJg6c5WCX1sTSpaGoyDN_Y0Od+9Qh+87FD4w@mail.gmail.com>
References: <146524175890.8042.12012703565205416569.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: maninder1.s@samsung.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:32812 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbcFFTh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 15:37:57 -0400
Received: by mail-oi0-f46.google.com with SMTP id k23so242856218oih.0
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 12:37:56 -0700 (PDT)
In-Reply-To: <146524175890.8042.12012703565205416569.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 6, 2016 at 3:35 PM, Paul Moore <pmoore@redhat.com> wrote:
> From: Paul Moore <paul@paul-moore.com>
>
> It seems risky to always rely on the caller to ensure the socket's
> address family is correct before passing it to the NetLabel kAPI,
> especially since we see at least one LSM which didn't. Add address
> family checks to the *_delattr() functions to help prevent future
> problems.
>
> Cc: <stable@vger.kernel.org>
> Reported-by: Maninder Singh <maninder1.s@samsung.com>
> Signed-off-by: Paul Moore <paul@paul-moore.com>
> ---
>  net/netlabel/netlabel_kapi.c |   12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)

DaveM, since this is such a trivial fix I'm adding it into my
selinux#next branch right now, but if you would prefer to carry it via
netdev#next let me know.

> diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
> index 1325776..bd007a9 100644
> --- a/net/netlabel/netlabel_kapi.c
> +++ b/net/netlabel/netlabel_kapi.c
> @@ -824,7 +824,11 @@ socket_setattr_return:
>   */
>  void netlbl_sock_delattr(struct sock *sk)
>  {
> -       cipso_v4_sock_delattr(sk);
> +       switch (sk->sk_family) {
> +       case AF_INET:
> +               cipso_v4_sock_delattr(sk);
> +               break;
> +       }
>  }
>
>  /**
> @@ -987,7 +991,11 @@ req_setattr_return:
>  */
>  void netlbl_req_delattr(struct request_sock *req)
>  {
> -       cipso_v4_req_delattr(req);
> +       switch (req->rsk_ops->family) {
> +       case AF_INET:
> +               cipso_v4_req_delattr(req);
> +               break;
> +       }
>  }
>
>  /**
>

-- 
paul moore
security @ redhat
