From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Controlling TCP window size
Date: Tue, 16 May 2006 16:01:57 -0700 (PDT)
Message-ID: <20060516.160157.78923603.davem@davemloft.net>
References: <4469B251.3050901@andyfurniss.entadsl.com>
	<446A19C7.1000302@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lists@andyfurniss.entadsl.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53389
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932250AbWEPXBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 19:01:49 -0400
To: jheffner@psc.edu
In-Reply-To: <446A19C7.1000302@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 16 May 2006 14:28:23 -0400

> The problem really is that the window_clamp variable is overloaded. 
> It's used as a kind of cache for rcvbuf -> window conversion, but also 
> as a user-settable bound in window size.  On examination, it looks like 
> this is also broken (in that window size won't increase) if a user does 
> a setsockopt(SO_RCVBUF).  Can we make window_clamp a true clamp?  Then 
> we can get rid of the hack of raising it in tcp_rcv_space_adjust().  I 
> can cook up a patch if interested.

The clamp gets moved along also to handle dynamic receive window
sizing.  To be honest, a window clamp doesn't have clear semantics
in the presence of dynamic window sizing.

Anyways, I'd like to see your patch.  It might make rcvbuf -->
window conversions a bit more expensive, but we'll see.

