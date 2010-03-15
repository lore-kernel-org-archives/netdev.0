From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/3] i4l: silence compiler warnings for array access in
 Eicon DIVA ISDN driver
Date: Mon, 15 Mar 2010 15:48:42 -0700 (PDT)
Message-ID: <20100315.154842.00466136.davem@davemloft.net>
References: <201003112207.o2BM7OZg013459@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org, imunsie@au.ibm.com,
	mac@melware.de, sgayda2@uiuc.edu
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34508
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936990Ab0COWsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 18:48:20 -0400
In-Reply-To: <201003112207.o2BM7OZg013459@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 11 Mar 2010 14:07:24 -0800

> From: Ian Munsie <imunsie@au.ibm.com>
> 
> When compiling this driver, the compiler throws the following warnings:
> 
> drivers/isdn/hardware/eicon/message.c:8426: warning: array subscript is above array bounds
> drivers/isdn/hardware/eicon/message.c:8427: warning: array subscript is above array bounds
> drivers/isdn/hardware/eicon/message.c:8434: warning: array subscript is above array bounds
> drivers/isdn/hardware/eicon/message.c:8435: warning: array subscript is above array bounds
> drivers/isdn/hardware/eicon/message.c:8436: warning: array subscript is above array bounds
> drivers/isdn/hardware/eicon/message.c:8447: warning: array subscript is above array bounds
> 
> This arises from the particular semantics the driver is using to write to
> the nlc array (static byte[256]).  The array has a length in byte 0
> followed by a T30_INFO struct starting at byte 1.
> 
> The T30_INFO struct has a number of variable length strings after the
> station_id entry, which cannot be explicitly defined in the struct and the
> driver accesses them with an array index to station_id beyond the length
> of station_id.
> 
> This patch merely changes the semantics that the driver uses to access the
> entries after the station_id entry to use the original 256 byte nlc array
> taking the offset and length of the station_id entry to calculate where to
> write in the array, thereby silencing the warning.
> 
> Signed-off-by: Ian Munsie <imunsie@au.ibm.com>
> Cc: Armin Schindler <mac@melware.de>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Cc: Stoyan Gaydarov <sgayda2@uiuc.edu>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
