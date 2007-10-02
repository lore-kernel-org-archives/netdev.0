From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 12:47:41 -0700
Message-ID: <4702A05D.6020509@hp.com>
References: <20070929142517.EC6AB5FB21@work.bitmover.com>	<alpine.LFD.0.999.0709290914410.3579@woody.linux-foundation.org>	<20070929172639.GB7037@bitmover.com>	<alpine.LFD.0.999.0709291050200.3579@woody.linux-foundation.org>	<20071002005917.GB5480@bitmover.com>	<alpine.LFD.0.999.0710011858400.3579@woody.linux-foundation.org>	<20071002022059.GE7037@bitmover.com> <47027C63.803@hp.com>	<20071002172002.GO17418@bitmover.com> <4702878B.4040102@hp.com> <20071002184032.GB29944@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	davem@davemloft.net, wscott@bitmover.com, netdev@vger.kernel.org
To: Larry McVoy <lm@bitmover.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:50288 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661AbXJBTrv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 15:47:51 -0400
In-Reply-To: <20071002184032.GB29944@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry McVoy wrote:
> On Tue, Oct 02, 2007 at 11:01:47AM -0700, Rick Jones wrote:
> 
>>has anyone already asked whether link-layer flow-control is enabled?
> 
> 
> I doubt it, the same test works fine in one direction and poorly in the other.
> Wouldn't the flow control squelch either way?

While I am often guilty of it, a wise old engineer tried to teach me that the 
proper spelling is ass-u-me :)  I wouldn't count on it hitting in both 
directions, depends on the specifics of the situation.

WRT the HP-UX ACK avoidance heuristic, the default HP-UX socket buffer/window is 
32768, and tcp_deferred_ack_max defaults to 22.  That isn't really all that good 
a combination - with a window of 32768 11 for the deferred ack would be better. 
  You could also go ahead and try it with a value of 2.  Or, bump the window 
size defaults - tcp_recv_hiwater_def and tcp_xmit_hiwater_def - to say 65535 or 
128K or something - or use the setsockopt() calls to effect that.

rick jones
