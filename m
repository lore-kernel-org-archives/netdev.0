From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Refactor to use macro for define diag nl
 request
Date: Sun, 19 Oct 2014 11:39:20 +0530
Message-ID: <20141019113920.3f0fa575@uryu.home.lan>
References: <1413676229-23258-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:53338 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbaJSGJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 02:09:41 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so3042500pdj.37
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 23:09:40 -0700 (PDT)
In-Reply-To: <1413676229-23258-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 19 Oct 2014 02:50:29 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  misc/ss.c | 57 ++++++++++++++++++---------------------------------------
>  1 file changed, 18 insertions(+), 39 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 2420b51..261847b 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -41,6 +41,20 @@
>  #include <linux/packet_diag.h>
>  #include <linux/netlink_diag.h>
>  
> +#define DIAG_REQUEST(_req, _r)						    \
> +	struct {							    \
> +		struct nlmsghdr nlh;					    \
> +		_r;							    \
> +	} _req = {							    \
> +		.nlh = {						    \
> +			.nlmsg_type = SOCK_DIAG_BY_FAMILY,		    \
> +			.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST,\
> +			.nlmsg_seq = 123456,				    \
> +			.nlmsg_len = sizeof(_req),			    \
> +			.nlmsg_pid = 0,					    \
> +		},							    \
> +	}

No need to initialize to zero.
Not a big fan of macro's but it does make the code more readable in this case.
