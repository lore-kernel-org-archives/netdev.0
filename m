From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] Use list_head-s in inetpeer.c
Date: Mon, 12 Nov 2007 11:57:23 +0300
Message-ID: <47381573.5020506@openvz.org>
References: <4735C11A.7060501@openvz.org> <20071110.213107.94486766.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56799 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755449AbXKLIyv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 03:54:51 -0500
In-Reply-To: <20071110.213107.94486766.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> Date: Sat, 10 Nov 2007 17:32:58 +0300
> 
>> The inetpeer.c tracks the LRU list of inet_perr-s, but makes
>> it by hands. Use the list_head-s for this.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> This makes every inetpeer struct consume 8 more bytes, and on some
> systems we have can have many of these objects active.  That space
> savings is why this was done the way it was.

No. I remove _two_ pointers unused_next and unused_prevp, and add
the list_head, which is _two_ pointers as well. I've even checked the
compilation on both i386 and x86_64 - the sizeof(struct inet_peer) 
is not changed.

You must have overlooked the unused_prevp member, because it is 
declared in the same line as the unused_next. Or I miss something else?

> It would be nice to have "tailq" like interfaces in linux/list.h
> for situations like this.
> 
> Please do not submit a patch implementing that until the 2.6.25
> merge window, however, thanks.

If my explanation above is correct, should I delay this patch until
the 2.6.25 anyway?

Thanks,
Pavel
