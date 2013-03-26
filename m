From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH Resend] af_unix: dont send SCM_CREDENTIAL when dest
 socket is NULL
Date: Mon, 25 Mar 2013 21:38:07 -0700
Message-ID: <1364272687.1716.12.camel@edumazet-glaptop>
References: <51510FAC.5090605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Li Zefan <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>,
	netdev@vger.kernel.org
To: dingtianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f175.google.com ([209.85.210.175]:60664 "EHLO
	mail-ia0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754881Ab3CZEiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 00:38:09 -0400
Received: by mail-ia0-f175.google.com with SMTP id y26so6175967iab.34
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 21:38:09 -0700 (PDT)
In-Reply-To: <51510FAC.5090605@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-26 at 11:02 +0800, dingtianhong wrote:
> SCM_SCREDENTIALS should apply to write() syscalls only either source or destination
> socket asserted SOCK_PASSCRED. The original implememtation in maybe_add_creds is wrong,
> and breaks several LSB testcases ( i.e. /tset/LSB.os/netowkr/recvfrom/T.recvfrom).
> 
> Origionally-authored-by: Karel Srot <ksrot@redhat.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  net/unix/af_unix.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 51be64f..99189fd 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1413,8 +1413,8 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
>  	if (UNIXCB(skb).cred)
>  		return;
>  	if (test_bit(SOCK_PASSCRED, &sock->flags) ||
> -	    !other->sk_socket ||
> -	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
> +	    (other->sk_socket &&
> +	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags))) {
>  		UNIXCB(skb).pid  = get_pid(task_tgid(current));
>  		UNIXCB(skb).cred = get_current_cred();
>  	}

Acked-by: Eric Dumazet <edumazet@google.com>
