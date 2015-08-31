From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: support global vtag assochash and per
 endpoint s(d)port assochash table
Date: Mon, 31 Aug 2015 15:16:00 -0700 (PDT)
Message-ID: <20150831.151600.1336251424367446992.davem@davemloft.net>
References: <6d09d44f7972c5a5e458fc0eef98aa057896403d.1441043068.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mleitner@redhat.com, vyasevic@redhat.com,
	daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52362 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbbHaWQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 18:16:01 -0400
In-Reply-To: <6d09d44f7972c5a5e458fc0eef98aa057896403d.1441043068.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue,  1 Sep 2015 01:44:28 +0800

> @@ -524,18 +524,16 @@ static inline int sctp_assoc_hashfn(struct net *net, __u16 lport, __u16 rport)
>  {
>  	int h = (lport << 16) + rport + net_hash_mix(net);
>  	h ^= h>>8;
> -	return h & (sctp_assoc_hashsize - 1);
> +	return h & (256 - 1);

It is not acceptable to use a magic constant for the hash table size.
You need to define this using a macro and use it consistently.

Furthermore, you should be looking into dynamically sized
hash tables because not everyone will need this many entries.
