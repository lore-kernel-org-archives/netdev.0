From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: tune back idle cwnd closing?
Date: Wed, 26 Apr 2006 15:27:38 -0700
Message-ID: <20060426152738.3a50d645@localhost.localdomain>
References: <44493980.1040708@oracle.com>
	<444E31D9.1010705@psc.edu>
	<20060426.144540.39973302.davem@davemloft.net>
	<444FF132.2080505@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, jheffner@psc.edu,
	zach.brown@oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:6560 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964873AbWDZW1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 18:27:51 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <444FF132.2080505@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Apr 2006 15:16:18 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> > When you're bursty application is not sending, other flows can take up
> > the pipe space you are not using, and you must reprobe to figure that
> > out.
> 
> If the "restarted" connection does normal slow-start, one of two things 
> will happen yes?  Either it will grow its cwnd to >= the receiver's 
> window, or it will have to stop before then because it triggered a 
> packet loss.
> 
> In the first case, seems it would have been just as good to let the 
> connection burst.
> 
> In the second case, is the effect on other connections really any better 
> than if the connection just started-up from where it was before?
> 
> BTW, is the RFC 2681?  I looked that one up on ietf.org and the RFC by 
> that number was a different beast entirely - at least at a very quick 
> glance.
> 
> rick jones
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

http://www.faqs.org/rfcs/rfc2861.html

   Long periods when the sender is application-limited can lead to the
   invalidation of the congestion window.  During periods when the TCP
   sender is network-limited, the value of the congestion window is
   repeatedly "revalidated" by the successful transmission of a window
   of data without loss.  When the TCP sender is network-limited, there
   is an incoming stream of acknowledgements that "clocks out" new data,
   giving concrete evidence of recent available bandwidth in the
   network.  In contrast, during periods when the TCP sender is
   application-limited, the estimate of available capacity represented
   by the congestion window may become steadily less accurate over time.
   In particular, capacity that had once been used by the network-
   limited connection might now be used by other traffic.
