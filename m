From: Hannes Eder <hannes@hanneseder.net>
Subject: Re: [PATCH 02/43] drivers/net/e2100.c: fix sparse warning: symbol
	shadows an earlier one
Date: Sun, 15 Feb 2009 20:57:59 +0100
Message-ID: <154e089b0902151157s6e185815jd86428518b58af6@mail.gmail.com>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	 <20090214211203.23489.80420.stgit@vmbox.hanneseder.net>
	 <499820DF.5070508@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: wharms@bfs.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f25.google.com ([209.85.220.25]:59547 "EHLO
	mail-fx0-f25.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbZBOT6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 14:58:04 -0500
In-Reply-To: <499820DF.5070508@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 15, 2009 at 3:04 PM, walter harms <wharms@bfs.de> wrote:
> Hi Hannes,
> it is ok to replace a fixed boarder with ARRAY_SIZE()
> in this special case i would success the following additional cleanup
> (untestet !!)
>
>
> static int set_free_irq(struct net_device *dev)
> {
>  int irqlist[] = {15,11,10,12,5,9,3,4}, i;
>
>        for (i = 0; i < ARRAY_SIZE(irqlist); i++)
>           if (request_irq (irqlist[i], NULL, 0, "bogus", NULL) != -EBUSY) {
>                        dev->irq = irqlist[i];
>                        return 0;
>            }
>        return -1;
> }
>
> ....
>
> if (dev->irq < 2) {
>         if ( set_free_irq(dev) < 0) {
>                printk(" unable to get IRQ %d.\n", dev->irq);
>                retval = -EAGAIN;
>                goto out;
>        }
>
> for me this looks more readable.
>
> getting a free interrupt from a list mus be a common problem ? I am not in driver programming
> perhaps such a code is already in place somewhere  ?

I am a great fan of refactoring but in that case I would just leave it
as is.  If extracting a method I would extract a little more here.

Best,
Hannes
