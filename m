From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] convert sbmac tx to spin_lock_irqsave to prevent early
 IRQ enable
Date: Thu, 25 Sep 2008 15:33:40 -0400
Message-ID: <48DBE794.9010309@garzik.org>
References: <6781da3918e3c34d23e5f7e9cf777ab463a17d5e.1221613284.git.weiwei.wang@windriver.com> <20080917114051.GA30734@shell.devel.redhat.com> <20080920201839.GA27700@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@redhat.com>,
	Weiwei Wang <weiwei.wang@windriver.com>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36882 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752742AbYIYTds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 15:33:48 -0400
In-Reply-To: <20080920201839.GA27700@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ralf Baechle wrote:
> On Wed, Sep 17, 2008 at 07:40:51AM -0400, Jeff Garzik wrote:
> 
>> On Wed, Sep 17, 2008 at 10:25:37AM +0800, Weiwei Wang wrote:
>>> Netpoll will call the interrupt handler with interrupts
>>> disabled when using kgdboe, so spin_lock_irqsave() should
>>> be used instead of spin_lock_irq() to prevent interrupts
>>> from being incorrectly enabled.
>>>
>>> Signed-off-by: Weiwei Wang <weiwei.wang@windriver.com>
>>> ---
>>>  drivers/net/sb1250-mac.c |   12 +++++++-----
>>>  1 files changed, 7 insertions(+), 5 deletions(-)
>> Please send to jeff@garzik.org or jgarzik@pobox.com.
> 
> Jeff - I haven't looked at kgdboe but if he's right half of drivers/net
> will need to be fixed ...

Oh indeed.  I mainly do it on a case-by-case basis where people care.  I 
overall think its a bogus change that deserves pushback, but that 
involves non-networking layers.  In the end, case-by-case application 
seemed to win.

	Jeff



