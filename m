From: Jouni Malinen <j@w1.fi>
Subject: Re: [GIT]: Networking
Date: Mon, 8 Sep 2008 19:55:25 -0700
Message-ID: <20080909025525.GB25148@hostap.isc.org>
References: <20080827.164649.87042354.davem@davemloft.net> <1220627292.7260.3.camel@2710p.home> <48C5E2FC.4090304@atheros.com> <20080908.194627.169864643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jouni.malinen@atheros.com, alex.williamson@hp.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, j@w1.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hostap.isc.org ([149.20.54.63]:57638 "EHLO hostap.isc.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752665AbYIIDb2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 23:31:28 -0400
Content-Disposition: inline
In-Reply-To: <20080908.194627.169864643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 07:46:27PM -0700, David Miller wrote:
> I'm so entirely tired of reading these 300+ column emails today that
> I'm just flat out refusing to read this one.
> 
> People, fix your setup please!  And if you have to get your email
> client to auto format your outgoing email text for you, that's fine.
> Although I can't understand why folks are too lazy to type enter every
> 80 columns or so.

Hmm.. I was using my temporary thunderbird setup and it is configured to
wordwrap at 72 character lines.. The mail server may have done something
odd, though. The version of the message I received directly at w1.fi was
word wrapped, so I have no idea what happened here. Anyway, since the
message was discussing your patchset, here's another version from mutt
(and another mail server) and which will hopefully show up in more
reasonable format.


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

-- 
Jouni Malinen                                            PGP id EFC895FA
