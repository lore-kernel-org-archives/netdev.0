From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] netconsole: fix NULL pointer dereference
Date: Fri, 25 Oct 2013 16:15:01 +0200
Message-ID: <526A7CE5.8040205@redhat.com>
References: <1382533489-19248-1-git-send-email-nikolay@redhat.com> <20131024102147.GD16787@redhat.com> <AE90C24D6B3A694183C094C60CF0A2F6026B73A9@saturn3.aculab.com> <20131024.135614.1725589105857635534.davem@davemloft.net> <52696563.1060507@redhat.com> <20131024205934.GA26855@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	vfalico@redhat.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967Ab3JYOSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Oct 2013 10:18:32 -0400
In-Reply-To: <20131024205934.GA26855@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2013 10:59 PM, Francois Romieu wrote:
> Nikolay Aleksandrov <nikolay@redhat.com> :
>> On 10/24/2013 07:56 PM, David Miller wrote:
>>> From: "David Laight" <David.Laight@ACULAB.COM>
> [...]
>>>> Ditto - might be worth saying:
>>>>     /* Acquire lock to wait for any write_msg() to complete. */
>>>
>>> Something this subtle definitely requires a comment.
>>>
>> Okay, thank you all for the reviews. I will re-submit a v2 with
>> the comment edited.
> 
> "edited" as in "removed" because:
> 1. an irq disabling spinlock loudly states what the intent is ("hey, this
>    netconsole stuff could be concurrently used in irq or softirq context").
> 2. the target_list_lock spinlock itself tells where to look for:
> 
> drivers/net/netconsole.c
> [...]
> /* This needs to be a spinlock because write_msg() cannot sleep */
> static DEFINE_SPINLOCK(target_list_lock);
> 
I thought so too. Although I also mentioned the problem and that it involves
write_msg in the current comment:
+		/* We need to disable the netconsole before cleaning it up
+		 * otherwise we might end up in write_msg() with
+		 * nt->np.dev == NULL and nt->enabled == 1
+		 */

I thought this implies that the spinlock protects us against running with
write_msg().
It's fine by me either way (with or w/o the addition to the comment). It's up to
you Dave, do you still want it explicitly there ?
