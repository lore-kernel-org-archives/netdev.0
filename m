From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] TCP limited slow start
Date: Mon, 5 Jun 2006 10:17:10 -0700
Message-ID: <20060605101710.762c0351@dxpl.pdx.osdl.net>
References: <20060602161312.3cb2ea66@localhost.localdomain>
	<20060602185403.1549e3c6@localhost.localdomain>
	<4481BD01.9020906@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15814 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751222AbWFERR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 13:17:26 -0400
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <4481BD01.9020906@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 03 Jun 2006 12:46:57 -0400
John Heffner <jheffner@psc.edu> wrote:

> Stephen Hemminger wrote:
> > Rolled my sleeve's up and gave this a try...
> > 
> > This is a implementation of Sally Floyd's Limited Slow Start
> > for Large Congestion Windows.
> 
> Limited slow start is useful as a work-around for bottleneck queues that 
> are inappropriately short.  I don't think it's good to run it all the 
> time by default (with a max_ssthresh < infinity), because it slows down 
> flows on healthy paths, and introduces another non-scalable parameter to 
> TCP.
> 
> I see it as potentially useful as a per-route parameter, where you set 
> it deliberately to work around some known problematic path.  A sysctl 
> with a default value of infinity might be okay as well.
> 
> Practically speaking, we've had this in the Web100 patch for a long time 
> (and still do, look for WAD_MaxSsthresh), but I've never found it all 
> that useful.  If the bottleneck queue is too short, you usually end up 
> getting screwed other ways too.
> 
>    -John

I moved it off to tcp_highspeed.c only. That is seems appropriate because
that is where you put the related RFC.
