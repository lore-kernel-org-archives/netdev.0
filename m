From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: connector: convert to synchronous netlink message processing
Date: Wed, 30 Mar 2011 17:39:13 +0400
Message-ID: <20110330133913.GA9425@ioremap.net>
References: <4D90D5E8.4080002@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:40403 "EHLO
	tservice.net.ru" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754861Ab1C3NjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 09:39:24 -0400
Content-Disposition: inline
In-Reply-To: <4D90D5E8.4080002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick

On Mon, Mar 28, 2011 at 08:39:36PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> This patch fixes up connector to work properly with the recent
> netlink changes that require synchronous netlink message processing.
> 
> The patch is so far only compile tested since I'm still looking
> for a good way to test it. If you could point me to some software
> using the proc events that would be appreciated.

There is test module in Documentation/connector/ and/or samples/ which I
used for tests. It was quite for a while when it was used last time
though.

Your patch looks very good and I definitely ack this :)
Thank you.

> commit 21c40e4675954b42c939334e3ed15e1bd0a4da29
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Mon Mar 28 20:20:26 2011 +0200
> 
>     connector: convert to synchronous netlink message processing
>     
>     Commits 01a16b21 (netlink: kill eff_cap from struct netlink_skb_parms)
>     and c53fa1ed (netlink: kill loginuid/sessionid/sid members from struct
>     netlink_skb_parms) removed some members from struct netlink_skb_parms
>     that depend on the current context, all netlink users are now required
>     to do synchronous message processing.
>     
>     connector however queues received messages and processes them in a work
>     queue, which is not valid anymore. This patch converts connector to do
>     synchronous message processing by invoking the registered callback handler
>     directly from the netlink receive function.
>     
>     In order to avoid invoking the callback with connector locks held, a
>     reference count is added to struct cn_callback_entry, the reference
>     is taken when finding a matching callback entry on the device's queue_list
>     and released after the callback handler has been invoked.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Acked-by: Evgeniy Polyakov <zbr@ioremap.net>


-- 
	Evgeniy Polyakov
