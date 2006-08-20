From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] getsockopt() early argument sanity checking
Date: Sun, 20 Aug 2006 18:30:51 +0200
Message-ID: <1156091451.23756.51.camel@laptopd505.fenrus.org>
References: <20060819230532.GA16442@openwall.com>
	 <200608201034.43588.ak@suse.de>  <20060820161602.GA20163@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, Willy Tarreau <wtarreau@hera.kernel.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:11501 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1750865AbWHTQbp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 12:31:45 -0400
To: Solar Designer <solar@openwall.com>
In-Reply-To: <20060820161602.GA20163@openwall.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> We're on UP.  sys_getsockopt() does get_user() (due to the patch) and
> makes sure that the passed *optlen is sane.  Even if this get_user()
> sleeps, the value it returns in "len" is what's currently in memory at
> the time of the get_user() return (correct?)  Then an underlying
> *getsockopt() function does another get_user() on optlen (same address),
> without doing any other user-space data accesses or anything else that
> could sleep first.  Is it possible that this second get_user()
> invocation would sleep?  I think not since it's the same address that
> we've just read a value from, we did not leave kernel space, and we're
> on UP (so no other processor could have changed the mapping).  So the
> patch appears to be sufficient for this special case (which is not
> unlikely).

this reasoning goes out the window with kernel preemption of course ;)


