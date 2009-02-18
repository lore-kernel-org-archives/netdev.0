From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFT 4/4] netfilter: Get rid of central rwlock in tcp conntracking
Date: Wed, 18 Feb 2009 10:56:45 +0100
Message-ID: <499BDB5D.2050105@trash.net>
References: <20090218051906.174295181@vyatta.com> <20090218052747.679540125@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47584 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553AbZBRJ4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 04:56:47 -0500
In-Reply-To: <20090218052747.679540125@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:

> @@ -50,6 +50,7 @@ struct ip_ct_tcp_state {
>  
>  struct ip_ct_tcp
>  {
> +	spinlock_t	lock;
>  	struct ip_ct_tcp_state seen[2];	/* connection parameters per direction */
>  	u_int8_t	state;		/* state of the connection (enum tcp_conntrack) */
>  	/* For detecting stale connections */

Eric already posted a patch to use an array of locks, which is
a better approach IMO since it keeps the size of the conntrack
entries down.
