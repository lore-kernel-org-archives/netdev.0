From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch net-next v3 2/3] bridge: only expire the mdb entry when
 query is received
Date: Thu, 2 May 2013 09:59:38 +0800
Message-ID: <20130502015938.GA2237@gondor.apana.org.au>
References: <1367305819-14013-1-git-send-email-amwang@redhat.com>
 <1367305819-14013-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:42855 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751790Ab3EBB7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 21:59:43 -0400
Content-Disposition: inline
In-Reply-To: <1367305819-14013-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 30, 2013 at 03:10:18PM +0800, Cong Wang wrote:
>
> @@ -1275,7 +1277,7 @@ static void br_multicast_leave_group(struct net_bridge *br,
>  		     br->multicast_last_member_interval;
>  
>  	if (!port) {
> -		if (mp->mglist &&
> +		if (mp->mglist && mp->timer_armed &&
>  		    (timer_pending(&mp->timer) ?
>  		     time_after(mp->timer.expires, time) :
>  		     try_to_del_timer_sync(&mp->timer) >= 0)) {

This whole section of code should now be removed since we're now
only arming the timer in response to a query to that group.  Of
course if we were the querier and sent out a query here then you'd
need to simulate the reception of a query.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
