From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/4] [NETLINK]: Dont set socket error for failed event
 notifications
Date: Thu, 10 Aug 2006 21:08:21 +0200
Message-ID: <44DB8425.8020108@trash.net>
References: <20060809204821.216122988@postel.suug.ch> <20060809205440.025848027@postel.suug.ch> <44DB765B.4020500@trash.net> <20060810190455.GI14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:8665 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S1750873AbWHJTKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 15:10:20 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060810190455.GI14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Patrick McHardy <kaber@trash.net> 2006-08-10 20:09
> 
>>I disagree with this patch, how else are applications supposed
>>to know when they missed an update and are not in sync anymore?
>>I actually have a half-finished patch to add this in some spots
>>where its missing (and uses better error codes).
> 
> 
> The application has no idea what went wrong nor does it know
> for which group so it will have to resync all group subscrptions
> and as it only happens due to memory pressure that will fail
> anyway.


The error code (-ENOMEM) gives it a pretty good idea what went
wrong. Its true that it doesn't know which group was affected
(that could be fixed), but at least it knows that something
went wrong and it needs to resync. If that fails due to memory
shortage as well it can schedule a delayed resync or something,
but without getting notified it has no chance of doing anything
useful. This makes notification essentially useless. If I can't
rely on either getting either a notification or an error, I can't
rely on them at all.

Please put this back in.
