From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC v2] net: add PCINet driver
Date: Wed, 5 Nov 2008 14:19:52 +0100
Message-ID: <200811051419.53194.arnd@arndb.de>
References: <20081029202027.GH12879@ovro.caltech.edu> <200811042123.03819.arnd@arndb.de> <20081104222927.GE4641@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan-Bernd Themann <THEMANN@de.ibm.com>
To: Ira Snyder <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:58848 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbYKENUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 08:20:11 -0500
In-Reply-To: <20081104222927.GE4641@ovro.caltech.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 04 November 2008, Ira Snyder wrote:

> So, since interrupts are disabled while my interrupt handler is running,
> I think I should be able to use spin_lock() and spin_unlock(), correct?

yes.

> But sparse gives me the following warning:
> wqt.c:185:9: warning: context imbalance in 'wqt_interrupt': wrong count at exit
> wqt.c:185:9:    context 'lock': wanted 0, got 1
> 
> If I'm using spin_lock_irqsave() and spin_lock_irqrestore() I do not get
> the same warnings. Therefore I must have some misunderstanding :)


I've seen something like that before, I think it was a bug either in
sparse or in the powerpc platform code. Try updating both the kernel
and sparse and see if it still happens.

	Arnd <><
