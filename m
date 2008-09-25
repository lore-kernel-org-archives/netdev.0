From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] convert sbmac tx to spin_lock_irqsave to prevent early
	IRQ enable
Date: Fri, 26 Sep 2008 00:49:10 +0100
Message-ID: <20080925234910.GA11092@linux-mips.org>
References: <6781da3918e3c34d23e5f7e9cf777ab463a17d5e.1221613284.git.weiwei.wang@windriver.com> <20080917114051.GA30734@shell.devel.redhat.com> <20080920201839.GA27700@linux-mips.org> <48DBE794.9010309@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@redhat.com>,
	Weiwei Wang <weiwei.wang@windriver.com>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ditditdahdahdah-dahditditditdit.dl5rb.org.uk ([217.169.26.26]:40074
	"EHLO ditditdahdahdah-dahdahdahditdit.dl5rb.org.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753476AbYIYXu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 19:50:26 -0400
Content-Disposition: inline
In-Reply-To: <48DBE794.9010309@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2008 at 03:33:40PM -0400, Jeff Garzik wrote:

>>> On Wed, Sep 17, 2008 at 10:25:37AM +0800, Weiwei Wang wrote:
>>>> Netpoll will call the interrupt handler with interrupts
>>>> disabled when using kgdboe, so spin_lock_irqsave() should
>>>> be used instead of spin_lock_irq() to prevent interrupts
>>>> from being incorrectly enabled.
>>>>
>>>> Signed-off-by: Weiwei Wang <weiwei.wang@windriver.com>
>>>> ---
>>>>  drivers/net/sb1250-mac.c |   12 +++++++-----
>>>>  1 files changed, 7 insertions(+), 5 deletions(-)
>>> Please send to jeff@garzik.org or jgarzik@pobox.com.
>>
>> Jeff - I haven't looked at kgdboe but if he's right half of drivers/net
>> will need to be fixed ...
>
> Oh indeed.  I mainly do it on a case-by-case basis where people care.  I  
> overall think its a bogus change that deserves pushback, but that  
> involves non-networking layers.  In the end, case-by-case application  
> seemed to win.

Turns out kgdboe isn't upstream yet - but netconsole apparently hast the
same issue.

  Ralf
