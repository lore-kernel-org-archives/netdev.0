From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] netem: correlated loss generation (v3)
Date: Wed, 19 May 2010 17:17:33 -0700
Message-ID: <20100519171733.71c24539@nehalam>
References: <4BD84428.30904@uniroma2.it>
	<20100517205621.036a06e0@nehalam>
	<20100519214239.GD5146@nuttenaction>
	<4BF46B90.1000806@uniroma2.it>
	<20100519230433.GE5146@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stefano Salsano <stefano.salsano@uniroma2.it>,
	David Miller <davem@davemloft.net>,
	Fabio Ludovici <fabio.ludovici@yahoo.it>,
	netdev@vger.kernel.org, netem@lists.linuxfoundation.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38142 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752307Ab0ETARj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 May 2010 20:17:39 -0400
In-Reply-To: <20100519230433.GE5146@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 May 2010 01:04:33 +0200
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> * Stefano Salsano | 2010-05-20 00:52:00 [+0200]:
> 
> >So my opinion is that the need to emulate "correlated" loss patterns
> >is not academic, but it is a real need from industry... of course we
> >can debate if it is a "niche" requirement or not
> 
> netem is not in the processing hot path, so there is no issue to add an
> additional component. If there are some[TM] users and it is usable, I am
> fine with this patch!
> 
> >tc qdisc change dev wlan0 root netem loss 2 10
> >
> >because this produces broken results...
> 
> How to model this specific network characteristic (2% loss, correlation 10%)
> with your modifications? Can you give us an example?

The old model was useful, but it really didn't do correlated loss.
For legacy, the old syntax will go through the same code and generate
the same result.

iproute2 syntax is not finalized but, plan is simplified version of
the NetemCLG paper.

tc qdisc change dev eth0 root netem 
      loss 2 10                              # compat syntax
      loss random 2 10                       # same as above
      loss deterministic file                # loss model based on bitmap
      loss state p13 [p31 [p32 [p23 [p14]]]] # 4 state 
      loss model  p [r [1-h [1-k]]]          # gilbert elliot model

Any suggestions for better syntax are appreciated.
