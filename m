From: Patrick McHardy <kaber@trash.net>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Thu, 05 Jul 2007 16:08:12 +0200
Message-ID: <468CFB4C.7040009@trash.net>
References: <1183492286.4021.21.camel@johannes.berg> <1183643610.5163.76.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64851 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756823AbXGEOIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 10:08:36 -0400
In-Reply-To: <1183643610.5163.76.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
>
>>Looking through the code that uses NL_NONROOT_SEND I just realised that
>>it's impossible to send multicast messages from userspace to multicast
>>groups with IDs higher than 31. That's not really good given that
>>everywhere else we handle multicast groups up to 2^32-1 :/
> 
> 
> Yes, this is TheWayItHasBeen(tm).
> Patrick had a patch a while back to allow for subscribing to higher
> groups because bind() has a similar issue in that it allows you only to
> subscribe to the first 32. So it is logical to fix connect, and sendmsg
> in a similar fashion.


For sendmsg I'd suggest to use cmsgs as in recvmsg().

