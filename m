From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3 2/3] bridge: only expire the mdb entry when
 query is received
Date: Fri, 03 May 2013 11:50:22 +0800
Message-ID: <1367553022.2415.55.camel@cr0>
References: <1367305819-14013-1-git-send-email-amwang@redhat.com>
	 <1367305819-14013-2-git-send-email-amwang@redhat.com>
	 <20130502015938.GA2237@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46342 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762408Ab3ECDuk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 May 2013 23:50:40 -0400
In-Reply-To: <20130502015938.GA2237@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-02 at 09:59 +0800, Herbert Xu wrote:
> On Tue, Apr 30, 2013 at 03:10:18PM +0800, Cong Wang wrote:
> >
> > @@ -1275,7 +1277,7 @@ static void br_multicast_leave_group(struct net_bridge *br,
> >  		     br->multicast_last_member_interval;
> >  
> >  	if (!port) {
> > -		if (mp->mglist &&
> > +		if (mp->mglist && mp->timer_armed &&
> >  		    (timer_pending(&mp->timer) ?
> >  		     time_after(mp->timer.expires, time) :
> >  		     try_to_del_timer_sync(&mp->timer) >= 0)) {
> 
> This whole section of code should now be removed since we're now
> only arming the timer in response to a query to that group.  Of
> course if we were the querier and sent out a query here then you'd
> need to simulate the reception of a query.

Hmm, this piece of code is checking if bridge itself is in the mdb entry
and if it just receives a leave, which seems still necessary... What am
I missing?

Thanks!
