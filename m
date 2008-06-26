From: Patrick McHardy <kaber@trash.net>
Subject: Re: Sending big Netlink messages to userspace
Date: Thu, 26 Jun 2008 02:41:20 +0200
Message-ID: <4862E5B0.9080007@trash.net>
References: <f4845fc0806240938h36d275ect109fd5f5414cba37@mail.gmail.com>	<4861282C.4000208@trash.net>	<20080625104401.GJ20815@postel.suug.ch> <20080625.155146.103043993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, juliusv@google.com, netdev@vger.kernel.org,
	vbusam@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36935 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbYFZAl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 20:41:27 -0400
In-Reply-To: <20080625.155146.103043993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Wed, 25 Jun 2008 12:44:01 +0200
> 
>> libnl initializes the buffer size to the size of a page. The value
>> can be overwritten by calling nl_set_buffer_size(socket, rx, tx)
> 
> And it doesn't need to be any larger than a page.  Actually, the
> hard upper bound is 8K.
> 
> The kernel will always chop the response up into chunks of that
> size or smaller when generating replies to userspace.
> 
> Therefore userland need never have a buffer larger than 8K or
> sysconf(_SC_PAGESIZE), whichever is smaller.

For dumps the size is fine, for large unicast messages it
might need to be increased though (like nfnetlink_queue).

