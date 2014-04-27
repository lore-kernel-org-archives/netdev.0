From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RESEND 2/2] FDDI: DEC FDDIcontroller 700
 TURBOchannel card support
Date: Sun, 27 Apr 2014 19:13:46 -0400 (EDT)
Message-ID: <20140427.191346.2115795102984045600.davem@davemloft.net>
References: <alpine.LFD.2.11.1404250159220.11598@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbaD0XNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 19:13:48 -0400
In-Reply-To: <alpine.LFD.2.11.1404250159220.11598@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Fri, 25 Apr 2014 10:35:15 +0100 (BST)

> +	/* Reset the board. */
> +	wmb();
> +	writew(FZA_RESET_INIT, &fp->regs->reset);
> +	iob();
> +	readw(&fp->regs->reset);	/* Read it back for a small delay. */
> +	iob();
> +	writew(FZA_RESET_CLR, &fp->regs->reset);

Using memory barriers around MMIO operations makes zero sense.

wmb() and friends order physical memory operations, and are only
to be used when the cpu must be synchronized with some other entity
looking at the same physical memory the cpu is, such as a device.

But that absolutely is not what is happening here, you're doing one
MMIO to non-physical memory after another.

> +{
> +	uint status, state;
> +
> +	unsigned long int flags;
> +	long int t;
> +

Use "unsigned int" and "long", and also please do not put empty lines
in the middle of the function variable declarations.

> +
> +	pr_info("%s: resetting the board...\n", fp->name);

Do not put more than one empty line between the local variables
and the first non-declaration statement of the function.

> +static struct fza_ring_cmd __iomem *fza_cmd_send(struct net_device *dev,
> +						 int command)

When a function declaration or definition or call spans multiple lines,
the second and subsequent lines should be indented to exactly the first
column after the openning parenthesis.

You must use the appropriate number of TAB and SPACE characters necessary
to do so.  Generally speaking, if you are only using TAB characters you
are indenting it incorrectly.

I'm sure there are lots of other coding style issues, please run
checkpatch on your changes unless you want to go back and forth
in review several more times as we find them too :-)

As per these SMT packets, don't even publish them to network taps.

We would have never seen them anyways, so keep them completely
internal to your driver.

That way you have no reason ti poke into internals like ptype_all
and dev_queue_xmit_nit().
