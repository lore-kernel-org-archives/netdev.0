From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] llc: convert the socket list to RCU locking (was
 Re: [PATCH 3/4] llc: use a device based hash table to speed up multicast
 delivery)
Date: Wed, 09 Dec 2009 21:52:50 +0100
Message-ID: <4B200E22.1060306@gmail.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <200912040130.54966.opurdila@ixiacom.com> <4B184F4C.3060407@gmail.com> <200912082310.45846.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:48709 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757844AbZLIUxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 15:53:05 -0500
Received: by fxm5 with SMTP id 5so8065177fxm.28
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2009 12:53:09 -0800 (PST)
In-Reply-To: <200912082310.45846.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote, On 12/08/2009 10:10 PM:

...
> @@ -652,10 +679,10 @@ static int llc_find_offset(int state, int ev_type)
>  void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk)
>  {
>  	llc_sap_hold(sap);
> -	write_lock_bh(&sap->sk_list.lock);
> +	spin_lock_bh(&sap->sk_lock);
>  	llc_sk(sk)->sap = sap;
> -	sk_add_node(sk, &sap->sk_list.list);
> -	write_unlock_bh(&sap->sk_list.lock);
> +	sk_nulls_add_node_rcu(sk, &sap->sk_list);
> +	spin_lock_bh(&sap->sk_lock);
------->^^^^^^^^^^


Jarek P.
