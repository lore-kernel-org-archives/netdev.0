From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] netlink: add socket destruction notification
Date: Thu, 05 Nov 2009 21:08:06 -0800 (PST)
Message-ID: <20091105.210806.40981707.davem@davemloft.net>
References: <1254473048.3959.76.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j@w1.fi, tgraf@suug.ch
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52480
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751538AbZKFFHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 00:07:40 -0500
In-Reply-To: <1254473048.3959.76.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 02 Oct 2009 10:44:08 +0200

> When we want to keep track of resources associated with applications, we
> need to know when an app is going away. Add a notification function to
> netlink that tells us that, and also hook it up to generic netlink so
> generic netlink can notify the families. Due to the way generic netlink
> works though, we need to notify all families and they have to sort out
> whatever resources some commands associated with the socket themselves.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

No fundamental objections.

However, as a followup, netlink_kernel_create() is becomming
function_that_takes_too_many_arguments().

At this point it's better to just pass two arguments, the network
namespace pointer, and a pointer to a "const struct netlink_kern_info"
that holds the rest of the parameters.

Could you make that change too?

Thanks!
