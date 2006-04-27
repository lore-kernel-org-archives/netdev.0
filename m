From: John Heffner <jheffner@psc.edu>
Subject: Re: tune back idle cwnd closing?
Date: Thu, 27 Apr 2006 13:47:33 -0400
Message-ID: <445103B5.2090603@psc.edu>
References: <44493980.1040708@oracle.com>	<444E31D9.1010705@psc.edu> <20060426.144540.39973302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zach.brown@oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:27844 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S965005AbWD0RtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 13:49:13 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060426.144540.39973302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: John Heffner <jheffner@psc.edu>
>> Given that RFC2681 is Experimental (and I'm not aware of any current 
>> efforts in the IETF to push it to the standard track), IHMO it would not 
>> be inappropriate to make this behavior controlled via sysctl.
> 
> I have to respectfully disagree.
> 
> This is the price you pay when the network's congestion is being
> measured by probing, information becomes stale over time if you don't
> send any probes.
> 
> And this change of congestion state is real and happens frequently for
> most end to end users.
> 
> When you're bursty application is not sending, other flows can take up
> the pipe space you are not using, and you must reprobe to figure that
> out.


A lot of the time doing 2861 is a good thing, since if you have a long 
pause, you've lost your ack clock, and you don't want to send a 
window-sized burst because you'll probably overflow a queue somewhere 
and step on your own feet.  Since we don't have a pacing mechanism, a 
slow start is really the only way to do this.

I don't entirely buy the "staleness" argument.  I don't think that *not* 
doing 2861 will affect the stability of congestion control, since all of 
the response mechanisms are still in place.  (Most OS's don't do 2861, 
and it is not a standard.)  If you have a long RTT, short RTT flows can 
make a big difference in congestion in a period much smaller than your 
timeout.  In fact, congestion information is *always* stale by the time 
you get it. :)

Sometimes having cwnd validation turned on will make your applications 
perform better, sometimes worse.  I don't think it would be incorrect to 
add a switch.  One question is whether it's worth adding the switch 
(i.e., do enough people care?).

Myself, I'd be interested to see some quantitative comparisons of 
performance with a "real" application affected by this.

Thanks,
   -John
