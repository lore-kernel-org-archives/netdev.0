From: James Morris <jmorris@namei.org>
Subject: Re: [IPSEC]: searching  SAD without assumming L3 details
Date: Sat, 2 Sep 2006 15:24:38 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609021519170.5804@d.namei>
References: <1157204582.5197.4.camel@jzny2>  <Pine.LNX.4.64.0609021102570.4222@d.namei>
 <1157217413.5077.17.camel@jzny2>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:18886 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751426AbWIBTYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Sep 2006 15:24:40 -0400
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1157217413.5077.17.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2 Sep 2006, jamal wrote:

> On Sat, 2006-02-09 at 11:04 -0400, James Morris wrote:
> > On Sat, 2 Sep 2006, jamal wrote:
> 
> > +       
> > +       spin_lock(&xfrm_state_lock);
> > 
> > Shouldn't this be spin_lock_bh()?
> > 
> > +       spin_unlock(&xfrm_state_lock);
> > +
> 
> the call is made at the moment only by pktgen (kernel threads on
> dev_queue_xmit level contending with softirqs essentially). I think
> (although havent tried) the spin_{un}lock_bh() wont work. Thoughts?

If bh's are already disabled when you call this, it'll be ok, but as this 
will be a generally exported function, I'd suggest using bh locking.  I 
guess you could also make a xfrm_stateonly_find_bh() to be called only 
with bh's disabled, if needed.


- James
-- 
James Morris
<jmorris@namei.org>

-- 
VGER BF report: U 0.523211
