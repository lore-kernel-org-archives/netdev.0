From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: TCP Spike
Date: Thu, 27 Sep 2007 07:33:46 -0700
Message-ID: <20070927073346.42d790dd@freepuppy.rosehill>
References: <F444CAE5E62A714C9F45AA292785BED3223F7283@esng11p33001.sg.csfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>
To: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49706 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756623AbXI0OeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 10:34:22 -0400
In-Reply-To: <F444CAE5E62A714C9F45AA292785BED3223F7283@esng11p33001.sg.csfb.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Sep 2007 11:58:01 +0800
"Majumder, Rajib" <rajib.majumder@credit-suisse.com> wrote:

> Hi,
> 
> We have observed 40ms latency spikes in TCP connections in "burst" type of traffic. This affects regular TCP sockets. We observed this issue in kernels of 2.4.21 and kernel 2.6.5.

Unfortunately, 2.6.5 is out of my short term memory at this point. I do remember that 2.6.5
used BIC for congestion control, and there were some math errors in the congestion control
logic that caused it to be way to aggressive.
  
> 
> Aparently, this seems to be fixed in 2.6.19.  
> 
> Can someone throw some light on this? 

My guess is that the addition of the SACK hinting might be the major win.  The code
takes 3 passes over the SACK list, so with large outstanding data that was a major
bottleneck, not sure if it was 4ms worth though.

> 
> Is this a congestion control/avoidance issue? What congestion control algorithm is used before 2.6.8?   

Default congestion control in early 2.6 was BIC, then after CUBIC stabilized it was made the default in 2.6.19.

Another thing that may cause changes in latency is Appropriate Byte Counting (ABC).
It was added in 2.6.14, but then turned off by default in 2.6.18.  The problem is
that ABC caused performance problems with some applications that sent messages
as many small writes.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
