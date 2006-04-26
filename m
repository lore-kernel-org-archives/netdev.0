From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tune back idle cwnd closing?
Date: Wed, 26 Apr 2006 14:45:40 -0700 (PDT)
Message-ID: <20060426.144540.39973302.davem@davemloft.net>
References: <44493980.1040708@oracle.com>
	<444E31D9.1010705@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zach.brown@oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11995
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932245AbWDZVpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 17:45:44 -0400
To: jheffner@psc.edu
In-Reply-To: <444E31D9.1010705@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 25 Apr 2006 10:27:37 -0400

> Yours is the first complaint of this kind I recall seeing, but I've 
> expected for a while someone would have this type of problem.  RFC2861 
> seems conceptually nice at first, but there are a few things about it 
> that bother me.  One thing in particular is that a naturally bursty 
> application (like yours) will actually perform better by padding its 
> connection with junk data whenever it doesn't have real data to send. 
> Or equivalently, it's punished for not sending data when it doesn't need 
> to.  I also think it may not do much good when there are connections 
> with significantly different RTTs.
> 
> Given that RFC2681 is Experimental (and I'm not aware of any current 
> efforts in the IETF to push it to the standard track), IHMO it would not 
> be inappropriate to make this behavior controlled via sysctl.

I have to respectfully disagree.

This is the price you pay when the network's congestion is being
measured by probing, information becomes stale over time if you don't
send any probes.

And this change of congestion state is real and happens frequently for
most end to end users.

When you're bursty application is not sending, other flows can take up
the pipe space you are not using, and you must reprobe to figure that
out.
