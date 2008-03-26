From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Improvev netconsole support for RTL8139 NIC driver
Date: Tue, 25 Mar 2008 23:14:11 -0400
Message-ID: <47E9BF83.8070006@pobox.com>
References: <47E9B115.9060109@windriver.com>	<47E9B39C.5010502@pobox.com> <20080325.194221.16658596.davem@davemloft.net> <47E9BA6C.2010502@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: yshi <yang.shi@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59825 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752660AbYCZDOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 23:14:16 -0400
In-Reply-To: <47E9BA6C.2010502@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

yshi wrote:
> David Miller =E5=86=99=E9=81=93:
>> From: Jeff Garzik <jgarzik@pobox.com>
>> Date: Tue, 25 Mar 2008 22:23:24 -0400
>>
>> =20
>>> This is bogus -- you should never need to slow down the hot path in=
=20
>>> such a way.
>>>    =20
>>
>> Slow down in what way?  Even on x86 saving the flags is just
>> about as expensive as a plain sti/cli.
>>
>> I would in fact prefer to see drivers unconditionally use
>> spin_lock_irqsave() et al. in the interrupt handler, for
>> consistency.
>>  =20
> Yes, I agree. Many NIC drivers do the same thing, like Gianfar, E1000=
, etc.

No, I just looked.  Neither gianfar nor e1000 nor e1000e does this.

In fact, gfar_transmit() is precisely an example of what I'm talking=20
about:  you only need to use spin_lock() there.

	Jeff



