From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] Fix pppol2tp getsockname()
Date: Tue, 20 Mar 2012 14:49:02 +0000
Message-ID: <4F6898DE.4020508@katalix.com>
References: <20120320135754.GA30155@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:47448 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760251Ab2CTOtH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2012 10:49:07 -0400
In-Reply-To: <20120320135754.GA30155@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/03/12 13:57, Benjamin LaHaise wrote:
> While testing L2TP functionality, I came across a bug in getsockname().  The
> IP address returned within the pppol2tp_addr's addr memember was not being
> set to the IP  address in use.  This bug is caused by using inet_sk() on the
> wrong socket (the L2TP socket rather than the underlying UDP socket), and was
> likely introduced during the addition of L2TPv3 support.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Signed-off-by: James Chapman <jchapman@katalix.com>

> ---
>  net/l2tp/l2tp_ppp.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
> index 96bc7a6..9b07191 100644
> --- a/net/l2tp/l2tp_ppp.c
> +++ b/net/l2tp/l2tp_ppp.c
> @@ -915,7 +915,7 @@ static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
>  		goto end_put_sess;
>  	}
>  
> -	inet = inet_sk(sk);
> +	inet = inet_sk(tunnel->sock);
>  	if (tunnel->version == 2) {
>  		struct sockaddr_pppol2tp sp;
>  		len = sizeof(sp);
