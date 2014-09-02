From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] sunvnet: Avoid sending superfluous LDC
 messages.
Date: Mon, 01 Sep 2014 20:48:57 -0700 (PDT)
Message-ID: <20140901.204857.987190951930176561.davem@davemloft.net>
References: <20140829202105.GI14753@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbaIBDs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 23:48:58 -0400
In-Reply-To: <20140829202105.GI14753@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Fri, 29 Aug 2014 16:21:05 -0400

> @@ -380,11 +390,14 @@ static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
>  	viodbg(DATA, "vnet_walk_rx start[%08x] end[%08x]\n", start, end);
>  
>  	while (start != end) {
> -		int ack = 0, err = vnet_walk_rx_one(port, dr, start, &ack);
> +		int retries;
> +		int ack = 0, err;
> +
> +		retries = 0;
> +again:
> +		err = vnet_walk_rx_one(port, dr, start, &ack);
>  		if (err == -ECONNRESET)
>  			return err;
> -		if (err != 0)
> -			break;
>  		if (ack_start == -1)
>  			ack_start = start;
>  		ack_end = start;

You're adding a function local label not even used by this patch.

Please be more careful with your patch submissions, I can see here
that you're bleeding patch #2 (which I disagree with) into this one
and you're not testing your changes individually as you should.
