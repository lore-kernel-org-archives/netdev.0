From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: slightly simplify keeping IPv6 addresses on link
 down
Date: Fri, 10 Dec 2010 12:43:39 -0800 (PST)
Message-ID: <20101210.124339.242120993.davem@davemloft.net>
References: <20101201122253.2a8be2e0@nehalam>
	<AANLkTin5f+BZnFEzuc6iPLC8Hp++V0Jam8aAU2jMvxQq@mail.gmail.com>
	<20101201130421.0ac08bcd@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lorenzo@google.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34256
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757096Ab0LJUnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 15:43:11 -0500
In-Reply-To: <20101201130421.0ac08bcd@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 1 Dec 2010 13:04:21 -0800

> On Wed, 1 Dec 2010 12:52:42 -0800
> Lorenzo Colitti <lorenzo@google.com> wrote:
> 
>> No, wait... The loop is protected by idev->lock, and the code just
>> before it that clears the temporary address list is essentially
>> identical (except it looks over tempaddr_list instead). Wouldn't that
>> blow up as well?
> 
> The old code walked the list until it was empty. New code could
> get confused if list changed by other changes during the
> period when idev->lock is dropped and notifier is called.

I think Stephen has a point here.

You can't use a "_safe" list traversal if you are dropping the
lock in the middle of that traversal, which is what you code
will be doing.

Lorenzo you've already added serious bugs to this code with your
previous address handling changes (which had reference counting bugs),
so I'm going to heavily scrutinize any "cleanup" or other kind of
change you try to make here.

In fact I really wish you would just leave this code as-is instead
of trying to make such pointless tweaks to it.

Thanks.
