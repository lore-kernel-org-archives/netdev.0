From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvtap: Resolve possible __might_sleep warning in
 macvtap_do_read()
Date: Mon, 09 Nov 2015 12:05:16 -0500 (EST)
Message-ID: <20151109.120516.1822300207198042759.davem@davemloft.net>
References: <1447078457-4965-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, mst@redhat.com,
	vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35229 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbbKIRFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 12:05:18 -0500
In-Reply-To: <1447078457-4965-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Mon,  9 Nov 2015 09:14:17 -0500

> macvtap_do_read code calls macvtap_put_user while it might be set up
> to wait for the user.  This results in the following warning:
 ...
> Make sure thet we call finish_wait() if we have the skb to process
> before trying to actually process it.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Oh I see, this is that new check in might_sleep() that makes sure
that the task state is TASK_RUNNING.

Looks good, applied, thanks.
