From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFT 3/4] Use mod_timer_noact to remove nf_conntrack_lock
Date: Wed, 18 Feb 2009 15:04:11 +0100
Message-ID: <499C155B.9010200@trash.net>
References: <20090218051906.174295181@vyatta.com> <20090218052747.555811553@vyatta.com> <499C14AF.60704@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	tglx@linutronix.de, netfilter-devel@vger.kernel.org,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53475 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbZBROEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 09:04:15 -0500
In-Reply-To: <499C14AF.60704@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Unfortunatly, this patch changes nothing, as most of the time, do_acct is true.
> 
> We also need to fine lock the accounting part as well.
> 
> 	spin_lock_bh(&ct->some_lock);
> 	acct = nf_conn_acct_find(ct);
> 	if (acct) {
> 		acct[CTINFO2DIR(ctinfo)].packets++;
> 		acct[CTINFO2DIR(ctinfo)].bytes +=
> 			skb->len - skb_network_offset(skb);
> 	}
> 	spin_unlock_bh(&ct->some_lock);
> 

Its currently still enabled by default, but we intend to change that.
After that I guess almost nobody will have it enabled.
