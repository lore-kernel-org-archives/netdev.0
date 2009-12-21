From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] 3c507.c: remove unused NULL pointer check
Date: Mon, 21 Dec 2009 21:46:23 +0100
Message-ID: <4B2FDE9F.1070108@hartkopp.net>
References: <200912211923.58735.strakh@ispras.ru>	<4B2FA8C7.3010509@hartkopp.net> <20091221123111.4498b17c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Strakh <strakh@ispras.ru>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Donald Becker <becker@scyld.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:43820 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757118AbZLUUqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 15:46:24 -0500
In-Reply-To: <20091221123111.4498b17c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 21 Dec 2009 17:56:39 +0100
> Oliver Hartkopp <socketcan@hartkopp.net> wrote:
> 
>> Alexander Strakh wrote:
>>> 	In driver drivers/net/3c507.c in function Iirqreturn_t el16_interrupt:
>>> 1. If in line 555 dev = NULL then we goto line 556
>>> 2. In line 556 we have null dereference because pr_err called with dev->name 
>>> in third parameter.
>>>  555        if (dev == NULL) {
>>>  556                pr_err("%s: net_interrupt(): irq %d for unknown device.
>>> \n",
>>>  557                        dev->name, irq);
>>>  558                return IRQ_NONE;
>>>  559        }
>>>
>>> Found by Linux Device Drivers Verification (Svace detector)
>>>
>>> Remove unused NULL pointer check.

> 
> Interrupts will never be called with third parameter of NULL. It is really
> bogus impossible to reach code.
> 

You're right! I just did not verify the direct assignment of dev = dev_id ...

Btw. the description for the reason of this patch remains unsuitably as the
problem is not the potential dereferencing of dev->name in pr_err() here.

It should better be something like this (partly stolen from your answer):

   Interrupts will never be called with dev_id parameter of NULL.
   This patch removes the obsolete, unreachable code.

Regards,
Oliver



