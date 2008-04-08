From: Patrick McHardy <kaber@trash.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Tue, 08 Apr 2008 23:19:42 +0200
Message-ID: <47FBE16E.6010504@trash.net>
References: <1203589042.17534.145.camel@johannes.berg>	 <1203616486.7181.269.camel@localhost>	<47BDBC23.5080007@trash.net>	 <20080223.200202.255773165.davem@davemloft.net>	 <47C2AAC8.8020202@trash.net> <1203969502.19319.279.camel@localhost>	 <47FBD30A.1010003@trash.net> <1207688549.1020.90.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	harvey.harrison@gmail.com, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52460 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbYDHVTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 17:19:46 -0400
In-Reply-To: <1207688549.1020.90.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Tue, 2008-04-08 at 22:18 +0200, Patrick McHardy wrote:
>
>> I've attached a codiff of a tree with and without this change
>> (might not include all drivers, but I think I enabled all that
>> build on x86_64). The _probe and _init_one functions should
>> be harmless, but there are lots of functions that look like
>> they would prefer to avoid useless overhead. A small sample:
>>
>> drivers/net/starfire.c:
>>    netdev_poll       |  +50
>>
>> drivers/net/tokenring/olympic.c:
>>    olympic_interrupt |  +10
> 
> []
> 
> I also think this should be cleaned up before 2.6.25 is released.

Great :)

> I think that the changes to pr_debug, dev_dbg, and dev_vdbg
> to use an "if (0) printk" macro rather than an empty inline
> I posted a few times without any reply or comment should work
> for most all cases.
> 
> These changes should allow gcc to eliminate unused functions
> called as arguments to those debugging logging functions
> while maintaining the printf argument validation.
> 
> I'll check out codiff as I haven't used it.
> Is this the latest codiff tool?
> http://git.kernel.org/?p=linux/kernel/git/acme/pahole.git;a=summary

Yes, I'm using pre-built debian packages though since
I couldn't get the source to work properly on debian
(deb ftp://ftp.nerim.net/debian/ sid main).

> Here is the patch again:

This might work (codiff should be able to tell). But I
just see that Dave also favours to use MAC_FMT directly,
so please just do this. Thanks.

