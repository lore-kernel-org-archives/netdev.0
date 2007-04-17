From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8320] New: replacing route in kernel doesn't
 send netlink message
Date: Tue, 17 Apr 2007 14:58:21 +0200
Message-ID: <4624C46D.1030609@trash.net>
References: <461D26CB.3010508@trash.net>	<1176400428.24446.40.camel@nt.wq.cz>	<4623029A.2090906@trash.net> <20070416.171016.43503207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: milon@wq.cz, akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32814 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753947AbXDQM6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 08:58:46 -0400
In-Reply-To: <20070416.171016.43503207.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 16 Apr 2007 06:59:06 +0200
> 
> 
>>RTM_DELROUTE + RTM_NEWROUTE seem to be safer, although you're correct
>>that it might cause userspace to perform some action upon receiving
>>the DELROUTE message since the update is non-atomic. So I really don't
>>know, I'm in favour of having notifications for replacements, but I
>>fear we might break something.
> 
> 
> We can cry foul about a broken application if an application following
> the API correctly would interpret the new messages correctly.
> 
> I think it doesn't make sense to do a delete then a newroute for
> the atomicity issues, and therefore the replace makes the most
> sense as long as existing correct uses of the API would not
> explode on this.


They shouldn't, worst case is that they ignore NLM_F_REPLACE and treat
it as a completely new route, which is at least half way correct and
not really worse than today.

Milan, could you cook up another patch which uses NLM_F_REPLACE?
