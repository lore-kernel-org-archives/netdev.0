From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 2/7] ss: Make sure index variable is >= 0
Date: Mon, 21 Aug 2017 17:34:04 -0700
Message-ID: <20170821173404.585ff766@xeon-e3>
References: <20170821170813.29697-1-phil@nwl.cc>
        <20170821170813.29697-3-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33795 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754242AbdHVAeG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 20:34:06 -0400
Received: by mail-pg0-f54.google.com with SMTP id s14so4243414pgs.1
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 17:34:06 -0700 (PDT)
In-Reply-To: <20170821170813.29697-3-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Aug 2017 19:08:08 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This shouldn't happen but relying upon external data without checking
> may lead to unexpected results.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  misc/ss.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 10360e5a04ff8..1ee02d73b2d7f 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -2004,7 +2004,7 @@ static void tcp_timer_print(struct tcpstat *s)
>  		"unknown"
>  	};
>  
> -	if (s->timer) {
> +	if (s->timer >= 0) {
>  		if (s->timer > 4)
>  			s->timer = 5;
>  		printf(" timer:(%s,%s,%d)",

Let's go one step deeper on this.
Why is s->timer an int, it should be unsigned. In which case the code in
print would not have to change.
