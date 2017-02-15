From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net] packet: Do not call fanout_release from atomic
 contexts
Date: Wed, 15 Feb 2017 13:02:31 -0800
Message-ID: <1487192551.1311.28.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1487190339-6366-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Anoob Soman <anoob.soman@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34159 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751383AbdBOVCd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 16:02:33 -0500
Received: by mail-pg0-f68.google.com with SMTP id v184so12047125pgv.1
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 13:02:33 -0800 (PST)
In-Reply-To: <1487190339-6366-1-git-send-email-anoob.soman@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-15 at 20:25 +0000, Anoob Soman wrote:

> +static struct packet_fanout *fanout_release(struct sock *sk)
>  {
>  	struct packet_sock *po = pkt_sk(sk);
>  	struct packet_fanout *f;
> @@ -1728,17 +1736,17 @@ static void fanout_release(struct sock *sk)
>  	if (f) {
>  		po->fanout = NULL;
>  
> -		if (atomic_dec_and_test(&f->sk_ref)) {
> +		if (atomic_dec_and_test(&f->sk_ref))
>  			list_del(&f->list);
> -			dev_remove_pack(&f->prot_hook);
> -			fanout_release_data(f);
> -			kfree(f);
> -		}
> +		else
> +			f = NULL;


Patch looks good, except this coding style issue.

if (...) {
        multi lines;
        expressions;
} else {
        f = NULL;
}


Not :

if (...) {
        multi lines;
        expressions;
} else
        f = NULL;
