From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139too: send NETDEV_CHANGE manually when autoneg is
 disabled
Date: Wed, 06 Mar 2013 15:53:23 -0500 (EST)
Message-ID: <20130306.155323.344491888348815531.davem@davemloft.net>
References: <1362596784-19443-1-git-send-email-vfalico@redhat.com>
	<1362601372.3126.23.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, netdev@vger.kernel.org, wfp5p@virginia.edu,
	jasowang@redhat.com, junchangwang@gmail.com,
	greearb@candelatech.com, ivecera@redhat.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551Ab3CFUxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 15:53:25 -0500
In-Reply-To: <1362601372.3126.23.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 6 Mar 2013 20:22:52 +0000

> On Wed, 2013-03-06 at 20:06 +0100, Veaceslav Falico wrote:
>> When setting autoneg off (with any additional parameters, like
>> speed/duplex), 8139too doesn't do an interface reset, and thus doesn't
>> notify anyone that its speed/duplex might have changed (bonding and bridge
>> will not see the speed changes, per example).
>>
>> Verify if we've force_media and send notification manually, so that the
>> listeners have a chance to see the changes. It's quite ugly, however I
>> don't see anything better.
> 
> Isn't this really a bug in mii_check_media()?  It shouldn't shortcut the
> calls to netif_carrier_{off,on}() just because mii->force_media is set.

I think mii_check_media() is responsible for handling this too.
