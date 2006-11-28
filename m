From: David Miller <davem@davemloft.net>
Subject: Re: Kevent POSIX timers support.
Date: Tue, 28 Nov 2006 11:13:00 -0800 (PST)
Message-ID: <20061128.111300.105813754.davem@davemloft.net>
References: <456B3016.9020706@redhat.com>
	<20061127.104955.48519839.davem@davemloft.net>
	<20061128091602.GC15083@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drepper@redhat.com, akpm@osdl.org, netdev@vger.kernel.org,
	zach.brown@oracle.com, hch@infradead.org,
	chase.venters@clientec.com, johann.borck@densedata.com,
	linux-kernel@vger.kernel.org, jeff@garzik.org, aviro@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:61891
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S936037AbWK1TMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 14:12:55 -0500
To: johnpol@2ka.mipt.ru
In-Reply-To: <20061128091602.GC15083@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 28 Nov 2006 12:16:02 +0300

> Although ukevent has pointer embedded, it is unioned with u64, so there
> should be no problems until 128 bit arch appeared, which likely will not
> happen soon. There is also unused in kevent posix timers patch
> 'u32 ret_val[2]' field, which can store segval's value too.
> 
> But the fact that ukevent does not and will not in any way have variable
> size is absolutely.

I believe that in order to be %100 safe you will need to use the
special aligned_u64 type, as that takes care of a crucial difference
between x86 and x86_64 API, namely that u64 needs 8-byte alignment on
x86_64 but not on x86.

You probably know this already :-)
