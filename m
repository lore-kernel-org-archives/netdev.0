From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch net-next v3 2/3] bridge: only expire the mdb entry when
 query is received
Date: Fri, 3 May 2013 12:01:02 +0800
Message-ID: <20130503040102.GA10898@gondor.apana.org.au>
References: <1367305819-14013-1-git-send-email-amwang@redhat.com>
 <1367305819-14013-2-git-send-email-amwang@redhat.com>
 <20130502015938.GA2237@gondor.apana.org.au>
 <1367553022.2415.55.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40270 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751212Ab3ECEBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 00:01:08 -0400
Content-Disposition: inline
In-Reply-To: <1367553022.2415.55.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 03, 2013 at 11:50:22AM +0800, Cong Wang wrote:
> On Thu, 2013-05-02 at 09:59 +0800, Herbert Xu wrote:
> > On Tue, Apr 30, 2013 at 03:10:18PM +0800, Cong Wang wrote:
> > >
> > > @@ -1275,7 +1277,7 @@ static void br_multicast_leave_group(struct net_bridge *br,
> > >  		     br->multicast_last_member_interval;
> > >  
> > >  	if (!port) {
> > > -		if (mp->mglist &&
> > > +		if (mp->mglist && mp->timer_armed &&
> > >  		    (timer_pending(&mp->timer) ?
> > >  		     time_after(mp->timer.expires, time) :
> > >  		     try_to_del_timer_sync(&mp->timer) >= 0)) {
> > 
> > This whole section of code should now be removed since we're now
> > only arming the timer in response to a query to that group.  Of
> > course if we were the querier and sent out a query here then you'd
> > need to simulate the reception of a query.
> 
> Hmm, this piece of code is checking if bridge itself is in the mdb entry
> and if it just receives a leave, which seems still necessary... What am
> I missing?

I think I quoted the wrong hunk in the patch, I meant the code
that arms the timer should no longer be in the leave_group function
unless we just sent a query ourselves (and in that case the expiration
should also be adjusted accordingly).

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
