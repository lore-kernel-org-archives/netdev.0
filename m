From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: TC-HTB issue : low throughput
Date: Mon, 9 Nov 2009 12:04:49 -0800
Message-ID: <20091109200448.GA13015@bougret.hpl.hp.com>
References: <20091107024305.GA32398@bougret.hpl.hp.com> <4AF60349.8000502@gmail.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:52836 "EHLO madara.hpl.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752515AbZKIUE5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2009 15:04:57 -0500
Content-Disposition: inline
In-Reply-To: <4AF60349.8000502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 08, 2009 at 12:31:21AM +0100, Jarek Poplawski wrote:
> Jean Tourrilhes wrote, On 11/07/2009 03:43 AM:
> 
> > Behaviour :
> > ---------
> > 
> > 	If I add classes 1:2 and 1:3 :
> > 	Each host independantly : ~170 Mb/s.
> > 	Both host together, for 10.10.10.38 : ~106 Mb/s ;
> > 	Both host together, for 10.10.10.33 : ~135 Mb/s
> > 
> > 	So, not only performance did drop significantely, but
> > prioritisation did not happen as expected.
> 
> If these eths are vlans (or other virtuals) something like this
> often happens if you forget to set dev's txqueuelen before
> adding classes (or a subqdisc with some 'limit').

	Thanks a lot ! I've just added :
ifconfig eth6.34 txqueuelen 5
	And now I get 450 Mb/s + 133 Mb/s. Not perfect, but much much
better, and probably good enough for now ;-)


> > 	I've noticed that /sbin/tc calculates a very low burst
> > value. This is due to the content of /proc/net/psched. I'm wondering
> > if the burst calculation is what causes the issue here.
> > 	However, I tried with "burst 50kb" and saw no difference...
> 
> There is (probably still) unfixed overflow in tc.
> 
> BTW, v2.6.31 should be more exact (but so much...) for above 100mbit
> scheduling, especially with this patch to iproute2:
> http://marc.info/?l=linux-netdev&m=124453482324409&w=2
> 
> Jarek P.

	Thanks. I'll look into upgrading.
	Regards,

	Jean
