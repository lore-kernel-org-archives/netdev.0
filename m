From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Wed, 14 Jul 2010 12:10:40 -0700
Message-ID: <20100714121040.4a674511@nehalam>
References: <4C3D94E3.9080103@wildgooses.com>
	<4C3DD5EB.9070908@tmr.com>
	<20100714.111553.104052157.davem@davemloft.net>
	<4C3E0684.5060409@wildgooses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, davidsen@tmr.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ed W <lists@wildgooses.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57765 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752530Ab0GNTKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 15:10:43 -0400
In-Reply-To: <4C3E0684.5060409@wildgooses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jul 2010 19:48:36 +0100
Ed W <lists@wildgooses.com> wrote:

> On 14/07/2010 19:15, David Miller wrote:
> > From: Bill Davidsen<davidsen@tmr.com>
> > Date: Wed, 14 Jul 2010 11:21:15 -0400
> >
> >    
> >> You may have to go into /proc/sys/net/core and crank up the
> >> rmem_* settings, depending on your distribution.
> >>      
> > You should never, ever, have to touch the various networking sysctl
> > values to get good performance in any normal setup.  If you do, it's a
> > bug, report it so we can fix it.
> >    
> 
> Just checking the basics here because I don't think this is a bug so 
> much as a, less common installation that differs from the "normal" case.
> 
> - When we create a tcp connection we always start with tcp slow start
> - This sets the congestion window to effectively 4 packets?
> - This applies in both directions?
> - Remote sender responds to my hypothetical http request with the first 
> 4 packets of data
> - We need to wait one RTT for the ack to come back and now we can send 
> the next 8 packets,
> - Wait for the next ack and at 16 packets we are now moving at a 
> sensible fraction of the bandwidth delay product?
> 
> So just to be clear:
> - We don't seem to have any user-space tuning knobs to influence this 
> right now?
> - In this age of short attention spans, a couple of extra seconds 
> between clicking something and it responding is worth optimising (IMHO)
> - I think I need to take this to netdev, but anyone else with any ideas 
> happy to hear them?
> 
> Thanks
> 
> Ed W

TCP slow start is required by the RFC. It is there to prevent a TCP congestion
collapse. The HTTP problem is exacerbated by things beyond the user's control:
  1. stupid server software that dribbles out data and doesn't used the full
    payload of the packets
  2. web pages with data from multiple sources (ads especially), each of which
    requires a new connection
  3. pages with huge graphics.

Most of this is because of sites that haven't figured out that somebody on a phone
across the globl might not have the same RTT and bandwidth that the developer on a
local network that created them.  Changing the initial cwnd isn't going to fix it.
