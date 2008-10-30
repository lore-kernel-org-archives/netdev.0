From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Thu, 30 Oct 2008 12:12:06 +0100
Message-ID: <1225365126.7803.66.camel@twins>
References: <20081008.114527.189056050.davem@davemloft.net>
	 <49077918.4050706@cosmosbay.com>	<490795FB.2000201@cosmosbay.com>
	 <20081028.220536.183082966.davem@davemloft.net>
	 <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com>
	 <4908627C.6030001@acm.org>  <490874F2.2060306@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com,
	Christoph Lameter <cl@linux-foundation.org>,
	johnpol@2ka.mipt.ru, Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:55713 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214AbYJ3LL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 07:11:56 -0400
In-Reply-To: <490874F2.2060306@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-29 at 15:36 +0100, Eric Dumazet wrote:
> +/**
> + * hlist_for_each_entry_rcu_safenext - iterate over rcu list of given type
> + * @tpos:      the type * to use as a loop cursor.
> + * @pos:       the &struct hlist_node to use as a loop cursor.
> + * @head:      the head for your list.
> + * @member:    the name of the hlist_node within the struct.
> + * @next:       the &struct hlist_node to use as a next cursor
> + *
> + * Special version of hlist_for_each_entry_rcu that make sure
> + * each next pointer is fetched before each iteration.
> + */
> +#define hlist_for_each_entry_rcu_safenext(tpos, pos, head, member, next) \
> +       for (pos = rcu_dereference((head)->first);                       \
> +               pos && ({ next = pos->next; smp_rmb(); prefetch(next); 1; }) && \
> +               ({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
> +               pos = rcu_dereference(next))
> +

why _safenext and not _safe like hlist_for_each_entry_safe() which also
keeps a next pointer?

Also note the difference in argument order between these two.

