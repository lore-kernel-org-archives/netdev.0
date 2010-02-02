From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] net: use helpers to access mc list
Date: Tue, 2 Feb 2010 17:03:48 +0100
Message-ID: <20100202160347.GB2601@psychotron.lab.eng.brq.redhat.com>
References: <20100126145738.GA2537@psychotron.lab.eng.brq.redhat.com>
 <20100202.072533.52179643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44393 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966Ab0BBQDx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2010 11:03:53 -0500
Content-Disposition: inline
In-Reply-To: <20100202.072533.52179643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 02, 2010 at 04:25:33PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Tue, 26 Jan 2010 15:57:39 +0100
>
>> Temporary macro "netdev_for_each_mc_addr" works in the ugly way, I'm aware, but
>> it will be replaced. It uses iterator stored in "struct net_device". In every
>> iteration, it copies addr from the list to "struct netdev_hw_addr" instance
>> (also stored in "struct net_device"). Driver reads address stored in this
>> structure. All is protected by addr_list_lock held by a caller.
>
>This kind of ugly hack is rarely necessary, so I'm not applying
>this, sorry.

Well, I admit it's ugly but it's only temporary. It would go away once all
drivers would be converted to use it (a matter of weeks/month tops I hope).

>
>In the macros, use the iterator type the driver instances already use,
>which is the mcaddr entry pointer.

You mean "struct dev_mc_list"? But that would solve nothing. If I would still
use current structure in drivers, then still the migration to struct_hw_addr
would be all-at-once for all drivers :( This patch was exacly made to avoid
this.

>
>Then by using list_for_each_entry() things should "just work".

Maybe I do not uderstand you correctly. Would you please explain?

Thanks a lot.

Jirka
