From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Use list_head-s in inetpeer.c
Date: Sat, 10 Nov 2007 21:31:07 -0800 (PST)
Message-ID: <20071110.213107.94486766.davem@davemloft.net>
References: <4735C11A.7060501@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58208
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751799AbXKKFbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 00:31:09 -0500
In-Reply-To: <4735C11A.7060501@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Sat, 10 Nov 2007 17:32:58 +0300

> The inetpeer.c tracks the LRU list of inet_perr-s, but makes
> it by hands. Use the list_head-s for this.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

This makes every inetpeer struct consume 8 more bytes, and on some
systems we have can have many of these objects active.  That space
savings is why this was done the way it was.

It would be nice to have "tailq" like interfaces in linux/list.h
for situations like this.

Please do not submit a patch implementing that until the 2.6.25
merge window, however, thanks.
