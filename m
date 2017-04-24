From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: macvlan: Fix device ref leak when purging bc_queue
Date: Mon, 24 Apr 2017 15:56:07 +0800
Message-ID: <20170424075606.GA19926@gondor.apana.org.au>
References: <1492618528011.11322@Dell.com>
 <20170420125512.GA9113@gondor.apana.org.au>
 <1492704599476.84165@Dell.com>
 <20170421044029.GA11695@gondor.apana.org.au>
 <1492785652578.53801@Dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Clifford.Wichmann@dell.com,
        netdev@vger.kernel.org
To: Joe.Ghalam@dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.176.57.175] ([198.176.57.175]:43624 "EHLO
        deadmen.hmeau.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1166260AbdDXH5Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 03:57:16 -0400
Content-Disposition: inline
In-Reply-To: <1492785652578.53801@Dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 02:40:50PM +0000, Joe.Ghalam@dell.com wrote:
> That's not true. macvlan_dellink() unregisters the queue, and macvlan_process_broadcast() will never get called. Please note that I'm not speculating. I have traced enabled on the dev_put and dev_hold, and I'm reporting a real, reproducible issue.

The only thing that can stop macvlan_process_broadcast from getting
called is macvlan_port_destroy.  Nothing else can stop the work
queue, unless of course the work queue mechanism itself is broken.

So if you're sure macvlan_port_destroy is never even called in
your case, then you'll need to start debugging the kernel work
queue mechanism to see why macvlan_process_broadcast is not getting
called.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
