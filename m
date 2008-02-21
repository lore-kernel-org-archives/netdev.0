From: Patrick McHardy <kaber@trash.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 18:45:11 +0100
Message-ID: <47BDB8A7.3070201@trash.net>
References: <1203586467.20345.14.camel@brick>	<20080221.015743.222059206.davem@davemloft.net>	<1203588079.20345.15.camel@brick> <20080221.020554.259219477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: harvey.harrison@gmail.com, joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:14578 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbYBURpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 12:45:34 -0500
In-Reply-To: <20080221.020554.259219477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Thu, 21 Feb 2008 02:01:19 -0800
> 
>> In this case, it's being passed to a debugfs create function, could it
>> instead use sysfs_format_mac?
> 
> Just assigning print_mac() to a local variable then passing that to
> debugfs_create_dir() will make the warning go away.
> 
>>From another perspective adding that __pure attribute to print_mac()
> might not have been the best idea.  But I can't think of another
> way to elimitate the "passing print_mac() args to pr_debug()
> still generates calls to print_mac() even when DEBUG is not
> defined" problem :-/


Frankly, I think the main problem is that MAC_FMT got removed
for no real reason and is forcing us to come up with lots of
workarounds. We have NIPQUAD_FMT, NIP6_FMT, so I don't see
whats wrong with MAC_FMT. In fact I think a simple

printk(MAC_FMT, addr);

is much nicer than all this temporary buffer and function
call stuff.
