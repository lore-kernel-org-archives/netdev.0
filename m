From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Sun, 16 Sep 2007 12:31:58 -0700 (PDT)
Message-ID: <20070916.123158.92582301.davem@davemloft.net>
References: <1189959274.4241.30.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36715
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751957AbXIPTb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 15:31:58 -0400
In-Reply-To: <1189959274.4241.30.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Sun, 16 Sep 2007 12:14:34 -0400

> Changes:
> I made changes to the code path as defined in the patch included to 
> and noticed a slight increase (2-3%) in performance with both e1000 and
> tg3; which was a relief because i thought the spinlock_irq (which is
> needed because some drivers grab tx lock in interupts) may have negative
> effects. The fact it didnt reduce performance was a good thing.
> Note: This is the highest end machine ive ever laid hands on, so this
> may be misleading.
>  
> So - what side effects do people see in doing this? If none, i will
> clean it up and submit.

I tried this 4 years ago, it doesn't work.  :-)

Many drivers, particularly very old ones that PIO packets into
a device which can take a long time, absolutely depend upon
interrupts being enabled fully during ->hard_start_xmit()
so that other high periority devices (such as simpler serial
controllers) can have their interrupts serviced during this
slow operation.

I don't think we want to do it anyways, whatever performance
we gain from it is offset by the badness of disabling interrupts
during this reasonably length stretch of code.

The -rt folks as a result would notice this too and spank us :-)
