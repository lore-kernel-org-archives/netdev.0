From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: RxConfig hack for the 8168evl.
Date: Tue, 26 Jun 2012 16:41:18 -0700 (PDT)
Message-ID: <20120626.164118.924203209791240399.davem@davemloft.net>
References: <20120620220918.GA2785@electric-eye.fr.zoreil.com>
	<DB5F775AE8124DDDAE4E1501A78AF7A3@realtek.com.tw>
	<20120626092251.GA1854@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org, thomas.pi@arcor.de
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37786 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221Ab2FZXlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 19:41:19 -0400
In-Reply-To: <20120626092251.GA1854@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 26 Jun 2012 11:22:51 +0200

> hayeswang <hayeswang@realtek.com> :
> [...]
>> The definition of the IO 0x44 bit 14 is opposite for new chips.
>> For 8111C, 0 means fetching one Rx descriptor, and 1 means fetching
>> multi-descriptors.
>> For 8111D and the later chips, 0 means fetching multi-descriptors, and 1 means
>> fetching one Rx descriptor.
> 
> Ok. Is there much point fetching one Rx descriptor versus several ?

It can help if the chip accesses enough at a time to fill a full cache
line.

In drivers I've written for chips that can do this, I've had the code
only post RX descriptors in chunks rather than one at a time, to
facilitate this even further.
