From: David Miller <davem@davemloft.net>
Subject: Re: [DST]: shrinks sizeof(struct rtable) by 64 bytes on x86_64
Date: Tue, 22 Jan 2008 06:18:52 -0800 (PST)
Message-ID: <20080122.061852.98841950.davem@davemloft.net>
References: <20080122115006.82dbbff4.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59800
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751072AbYAVOSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:18:45 -0500
In-Reply-To: <20080122115006.82dbbff4.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 22 Jan 2008 11:50:06 +0100

> On x86_64, sizeof(struct rtable) is 0x148, which is rounded up to 0x180
> bytes by SLAB allocator.
> 
> We can reduce this to exactly 0x140 bytes, without alignment overhead,
> and store 12 struct rtable per PAGE instead of 10.
> 
> rate_tokens is currently defined as an "unsigned long", while its content
> should not exceed 6*HZ. It can safely be converted to an unsigned int.
> 
> Moving tclassid right after rate_tokens to fill the 4 bytes hole permits
> to save 8 bytes on 'struct dst_entry', which finally permits to save 8
> bytes on 'struct rtable'
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Thanks for doing this work Eric.

Patch applied.
