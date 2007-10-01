From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 Rev4] Initilize and populate age field
Date: Sun, 30 Sep 2007 17:41:54 -0700 (PDT)
Message-ID: <20070930.174154.39184307.davem@davemloft.net>
References: <20070920205751.dfaa34d8.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, socketcan@hartkopp.net,
	shemminger@linux-foundation.org, krkumar2@in.ibm.com,
	tgraf@suug.ch, varuncha@in.ibm.com
To: varunc@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55565
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751107AbXJAAly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 20:41:54 -0400
In-Reply-To: <20070920205751.dfaa34d8.varunc@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Date: Thu, 20 Sep 2007 20:57:51 +0530

> @@ -420,6 +421,7 @@ static int fn_hash_insert(struct fib_tab
>  	else
>  		fa = fib_find_alias(&f->fn_alias, tos, fi->fib_priority);
>  
> +	do_gettimeofday(&tv);
>  	/* Now fa, if non-NULL, points to the first fib alias
>  	 * with the same keys [prefix,tos,priority], if such key already
>  	 * exists or to the node before which we will insert new one.

gettimeofday() is expensive, we don't even use it to timestamp every
incoming packet and we therefore should not do it every route cache
entry we create in order to handle DoS situations efficiently

I honestly don't like these patches.  I literally cringe every time
you post a new revision.  It's either going to add new costs to route
management or be so inaccurate as to be useless.

I question it's usefulness even if implemented efficiently and
accurately.  I really don't see people lining up asking for a route
aging metric.

We could report zero and be compliant with the RFC, we don't age our
route entries like the model of the SNMP vars seems to suggest, so
it's honestly accurate.  And this would mean no kernel changes, as the
userland program could just report zero in the absense of a kernel
provided value.
