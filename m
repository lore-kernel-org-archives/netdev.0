From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] net: dev: deinit list in unregister_netdevice_many
Date: Wed, 27 Feb 2013 15:31:26 +0800
Message-ID: <512DB64E.6010103@cn.fujitsu.com>
References: <1361948391-4906-1-git-send-email-gaofeng@cn.fujitsu.com> <20130227.022125.374228548587492555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:4280 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752537Ab3B0Hal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 02:30:41 -0500
In-Reply-To: <20130227.022125.374228548587492555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/02/27 15:21, David Miller wrote:
> 
> mroute_clean_tables() uses the list after unregister_netdevice_many().
>

You mean list_for_each_entry_safe(c, next, &mrt->mfc_cache_array[i], list)
in mroute_clean_tables()?

Isn't this list just a member of struct mfc_cache?
I can't find the other codes in mroute_clean_tables uses this list
after unregister_netdevice_many.

> Can you please just stop tinkering in this area?  You are making many
> careless errors.
> 

Ok,I am fine if you drop this patch,just as commit ceaaec98ad99859ac90ac6863ad0a6cd075d8e0e
said "device is freed without touching its unreg_list". there will be no serious problems
if we don't have this patch.
