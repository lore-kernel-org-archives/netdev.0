From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ptp: dynamic allocation of PHC char devices
Date: Wed, 10 Apr 2013 13:49:27 -0400 (EDT)
Message-ID: <20130410.134927.1751916446892581975.davem@davemloft.net>
References: <4a1dcbcfb28ea2d18b09561a370efe7a4b0a2c5f.1365590805.git.jbenc@redhat.com>
	<1365615436.2581.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org, richardcochran@gmail.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50170 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933146Ab3DJRt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 13:49:28 -0400
In-Reply-To: <1365615436.2581.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 10 Apr 2013 18:37:16 +0100

> On Wed, 2013-04-10 at 12:47 +0200, Jiri Benc wrote:
>> As network adapters supporting PTP are becoming more common, machines with
>> many NICs suddenly have many PHCs, too. The current limit of eight /dev/ptp*
>> char devices (and thus, 8 network interfaces with PHC) is insufficient. Let
>> the ptp driver allocate the char devices dynamically.
>> 
>> The character devices are allocated in chunks. idr is used for tracking
>> minor numbers allocation; the mapping from index to pointer is not used, as
>> it is not needed for posix clocks.
> [...]
> 
> I don't understand why you want to dynamically allocate chunks of minor
> numbers, rather than the full range.  Unused minors don't seem to cost
> anything.

Can't multiple (unrelated) devices carve out minor space in the same
major?  Isn't that why it's designed this way?
