From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: macvlan: Fix device ref leak when purging bc_queue
Date: Fri, 21 Apr 2017 12:40:29 +0800
Message-ID: <20170421044029.GA11695@gondor.apana.org.au>
References: <1492618528011.11322@Dell.com>
 <20170420125512.GA9113@gondor.apana.org.au>
 <1492704599476.84165@Dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Clifford.Wichmann@dell.com,
        netdev@vger.kernel.org
To: Joe.Ghalam@dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.176.57.175] ([198.176.57.175]:42640 "EHLO
        deadmen.hmeau.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752493AbdDUElY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 00:41:24 -0400
Content-Disposition: inline
In-Reply-To: <1492704599476.84165@Dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 04:09:56PM +0000, Joe.Ghalam@dell.com wrote:
> I agree with this change, but the same purge would be needed for the macvlan_dellink() call also. 

I don't think that's necessary because as long as the master
device is still around it will continue to process the broadcast
queue, thus removing any reference counts held.

It's only when the queue is purged that we run into trouble.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
