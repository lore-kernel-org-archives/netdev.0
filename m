From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/8] net: Kill hold_net release_net
Date: Wed, 11 Mar 2015 10:10:13 -0700
Message-ID: <1426093813.11398.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	 <CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	 <87d25hrv9m.fsf@x220.int.ebiederm.org>
	 <20150219.144929.1003473344851168804.davem@davemloft.net>
	 <87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	 <87vbi7fq92.fsf_-_@x220.int.ebiederm.org>
	 <87pp8ffq63.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	hannes@stressinduktion.org, ddutt@cumulusnetworks.com,
	vipin@cumulusnetworks.com, shmulik.ladkani@gmail.com,
	dsahern@gmail.com, Julian Anastasov <ja@ssi.bg>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:33449 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbbCKRKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:10:17 -0400
Received: by iecvj10 with SMTP id vj10so366119iec.0
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 10:10:17 -0700 (PDT)
In-Reply-To: <87pp8ffq63.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 11:35 -0500, Eric W. Biederman wrote:

> diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
> index 6d592f8555fb..e0d5c8327159 100644
> --- a/net/ipv4/inet_timewait_sock.c
> +++ b/net/ipv4/inet_timewait_sock.c
> @@ -98,7 +98,7 @@ void inet_twsk_free(struct inet_timewait_sock *tw)
>  #ifdef SOCK_REFCNT_DEBUG
>  	pr_debug("%s timewait_sock %p released\n", tw->tw_prot->name, tw);
>  #endif
> -	release_net(twsk_net(tw));
> +	twsk_net(tw);
>  	kmem_cache_free(tw->tw_prot->twsk_prot->twsk_slab, tw);
>  	module_put(owner);
>  }


Not clear why you left this line ?
