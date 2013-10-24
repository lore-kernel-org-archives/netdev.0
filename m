From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net] netconsole: fix NULL pointer dereference
Date: Thu, 24 Oct 2013 22:59:34 +0200
Message-ID: <20131024205934.GA26855@electric-eye.fr.zoreil.com>
References: <1382533489-19248-1-git-send-email-nikolay@redhat.com>
 <20131024102147.GD16787@redhat.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B73A9@saturn3.aculab.com>
 <20131024.135614.1725589105857635534.davem@davemloft.net>
 <52696563.1060507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	vfalico@redhat.com, netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54593 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755240Ab3JXU7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 16:59:50 -0400
Content-Disposition: inline
In-Reply-To: <52696563.1060507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> :
> On 10/24/2013 07:56 PM, David Miller wrote:
> > From: "David Laight" <David.Laight@ACULAB.COM>
[...]
> >> Ditto - might be worth saying:
> >>     /* Acquire lock to wait for any write_msg() to complete. */
> > 
> > Something this subtle definitely requires a comment.
> > 
> Okay, thank you all for the reviews. I will re-submit a v2 with
> the comment edited.

"edited" as in "removed" because:
1. an irq disabling spinlock loudly states what the intent is ("hey, this
   netconsole stuff could be concurrently used in irq or softirq context").
2. the target_list_lock spinlock itself tells where to look for:

drivers/net/netconsole.c
[...]
/* This needs to be a spinlock because write_msg() cannot sleep */
static DEFINE_SPINLOCK(target_list_lock);

-- 
Ueimor
