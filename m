From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [patch 3/5] ATM: he: fix section mismatch
Date: Tue, 19 Sep 2006 23:05:08 -0700
Message-ID: <adaslinjcob.fsf@cisco.com>
References: <200609200108.k8K18oW2011719@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:50082 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S1750803AbWITGFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 02:05:14 -0400
To: akpm@osdl.org
In-Reply-To: <200609200108.k8K18oW2011719@shell0.pdx.osdl.net> (akpm@osdl.org's message of "Tue, 19 Sep 2006 18:08:50 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > WARNING: drivers/atm/he.o - Section mismatch: reference to .init.text: from .text between 'he_start' (at offset 0x218a) and 'he_service_tbrq'

 > -static int __init
 > +static int __devinit
 >  he_init_group(struct he_dev *he_dev, int group)

There are a ton of other __init functions (he_init_irq(),
he_init_tx_lbfp(), etc.) called from the __devinit function he_start()
in this driver.  So I think this patch is insufficient -- does it even
really fix the warning??  (I think -funit-at-a-time hides the warning
with this patch on x86-64)

Anyway, I sent a more comprehensive fix to Chas who forwarded it to
DaveM already.

 - R.
