From: jamal <hadi@cyberus.ca>
Subject: Re: [IPSEC]: searching  SAD without assumming L3 details
Date: Sat, 02 Sep 2006 13:16:53 -0400
Message-ID: <1157217413.5077.17.camel@jzny2>
References: <1157204582.5197.4.camel@jzny2>
	 <Pine.LNX.4.64.0609021102570.4222@d.namei>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:56968 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751214AbWIBRRA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Sep 2006 13:17:00 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GJZ75-0006Tp-LT
	for netdev@vger.kernel.org; Sat, 02 Sep 2006 13:16:59 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0609021102570.4222@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-02-09 at 11:04 -0400, James Morris wrote:
> On Sat, 2 Sep 2006, jamal wrote:

> +       
> +       spin_lock(&xfrm_state_lock);
> 
> Shouldn't this be spin_lock_bh()?
> 
> +       spin_unlock(&xfrm_state_lock);
> +

the call is made at the moment only by pktgen (kernel threads on
dev_queue_xmit level contending with softirqs essentially). I think
(although havent tried) the spin_{un}lock_bh() wont work. Thoughts?
Obviously the easy thing for me to do is change it and see what
happens;->

> +       if (rx)
> +               xfrm_state_hold(rx);
> 
> I think you need to grab the reference before letting go of the lock.
> 

I believe you are right. I will make the change, retest and repost.

> 
> Can you please include patches inline, or tell me how to get pine to 
> quote attachments? :-)

I could get evolution to inline attachments although last time i tried
it made Dave unhappy with not being to use git am or some such
reason ;-> I think some white spaces get added or some other mangling
happens.
I could try it on the repost.

Thanks for the comments James.

cheers,
jamal




-- 
VGER BF report: U 0.500005
