From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] yam: avoid null pointer dereference error
Date: Wed, 27 Mar 2013 14:14:18 -0400 (EDT)
Message-ID: <20130327.141418.1896219780137435502.davem@davemloft.net>
References: <20130327.134651.702432728001011428.davem@davemloft.net>
	<5153358A.5010505@canonical.com>
	<1364407953.2922.12.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: colin.king@canonical.com, jpr@f6fbb.org,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052Ab3C0SOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 14:14:21 -0400
In-Reply-To: <1364407953.2922.12.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 Mar 2013 18:12:33 +0000

> On Wed, 2013-03-27 at 18:08 +0000, Colin Ian King wrote:
>> On 27/03/13 17:46, David Miller wrote:
>> > From: Ben Hutchings <bhutchings@solarflare.com>
>> > Date: Wed, 27 Mar 2013 17:44:17 +0000
>> >
>> >> On Wed, 2013-03-27 at 11:19 +0000, Colin King wrote:
>> >>> From: Colin Ian King <colin.king@canonical.com>
>> >>>
>> >>> yam_open checks if dev is null, however, before that check it
>> >>> accesses some of the fields from dev in a proceeding printk which
>> >>> will cause a null pointer dereference error if dev is nul. Move
>> >>> the printk to after the null check.
>> >>
>> >> This function will never be called with dev == NULL.
>> >
>> > Then let's remove at least that part of the check.
>> >
>> Good point. How about the following..
> 
>> From 564f111f196d9d7293e922a68ba973210d191129 Mon Sep 17 00:00:00 2001
>> From: Colin Ian King <colin.king@canonical.com>
>> Date: Wed, 27 Mar 2013 13:59:05 -0400
>> Subject: [PATCH] yam: remove redundant null check on dev
>> 
>> yam_open has a redundant null check on null,  it will
>> never be called with dev == NULL. Remove this redundant check.
>> This also cleans up a smatch warning:
>> 
>> drivers/net/hamradio/yam.c:869 yam_open() warn: variable
>>   dereferenced before check 'dev' (see line 867)
>> 
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> 
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Colin, please formally resubmit this using a fresh mailing list
posting rather than as a reply in this thread.  Please incorporate
Ben's reviewed-by tag when doing so, thanks.
