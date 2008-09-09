From: Jouni Malinen <jouni.malinen@atheros.com>
Subject: Re: [GIT]: Networking
Date: Tue, 9 Sep 2008 05:44:12 +0300
Message-ID: <48C5E2FC.4090304@atheros.com>
References: <20080827.164649.87042354.davem@davemloft.net> <1220627292.7260.3.camel@2710p.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<j@w1.fi>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:39793 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973AbYIICmF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 22:42:05 -0400
In-Reply-To: <1220627292.7260.3.camel@2710p.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex Williamson wrote:
> On Wed, 2008-08-27 at 16:46 -0700, David Miller wrote:
> 
>> 22) Two mac80211 bug fixes from Jouni Malinen:
>>     a) Use IWEVCUSTOM so that we don't hit the 256 byte limit that
>>        IWEVASSOCREQIE has

By the way, that description is incorrect; the change was in the other 
direction (i.e., to use IWSSOCREQIE).

> This one breaks wireless with 32bit userspace/64bit kernel.  Bisected
> back to changeset 087d833e5a9f67ba933cb32eaf5a2279c1a5b47c:
> 
> mac80211: Use IWEVASSOCREQIE instead of IWEVCUSTOM

Great.. I was hoping that the WEXT compat ioctl fixes from Dave resolved 
all WEXT cases. This code is (and was) using wireless_send_event() and I 
did not find clear changes to its use in Dave's patch set. Was that 
supposed to be fixed with the compat ioctl patches? I'm not very 
familiar with this area and don't have an easy way to test this now (I'm 
traveling and don't have access to a 64/32-bit setup).

As far as I can tell, the commit mentioned here is correct in itself, 
but it looks like the WEXT code would not handle something properly for 
wireless_send_event(). I'm not sure why IWEVCUSTOM would work any 
better, but well, maybe it does not have some fields that get wrong in 
64/32 case or the previous working case ended up getting the 
too-long-buffer error which prevented the message from being processed 
in userspace).

What exactly does "breaks wireless" mean here?

As far as resolving this quickly is concerned, reverting the change is 
fine; this is not a critical issue with most use cases. Anyway, this 
should really be fixed eventually, but it looks like someone would need 
to fix WEXT for wireless_send_event() first..

- Jouni
