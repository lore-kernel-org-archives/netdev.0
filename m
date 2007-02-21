From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Wed, 21 Feb 2007 14:06:34 +0300
Message-ID: <20070221110634.GA30394@2ka.mipt.ru>
References: <20070219231447.GA4400@outpost.ds9a.nl> <p73d545drx6.fsf@bingen.suse.de> <20070220162714.GA3245@outpost.ds9a.nl> <20070220164124.GA24930@2ka.mipt.ru> <20070220170232.GA4730@outpost.ds9a.nl> <20070220171120.GD24930@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bert hubert <bert.hubert@netherlabs.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:48498 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203AbXBULHf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 06:07:35 -0500
Content-Disposition: inline
In-Reply-To: <20070220171120.GD24930@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is data for 50 bytes reading for essentially idle machine 
(core duo 2.4 ghz):

delta for syscall: 3326961404-3326969261: 7857 cycles = 3.273750 us
delta for syscall: 3326975687-3326980979: 5292 cycles = 2.205000 us
delta for syscall: 3327199967-3327205583: 5616 cycles = 2.340000 us
delta for syscall: 3327208706-3327214817: 6111 cycles = 2.546250 us
delta for syscall: 3327442427-3327450446: 8019 cycles = 3.341250 us
delta for syscall: 3327453281-3327459104: 5823 cycles = 2.426250 us
delta for syscall: 3327462002-3327466844: 4842 cycles = 2.017500 us
delta for syscall: 3327726809-3327733451: 6642 cycles = 2.767500 us
delta for syscall: 3327736178-3327741947: 5769 cycles = 2.403750 us
delta for syscall: 3327968972-3327974264: 5292 cycles = 2.205000 us
delta for syscall: 3327977981-3327984506: 6525 cycles = 2.718750 us
delta for syscall: 3327987215-3327991958: 4743 cycles = 1.976250 us
delta for syscall: 3328245416-3328252058: 6642 cycles = 2.767500 us
delta for syscall: 3328258646-3328264172: 5526 cycles = 2.302500 us

and sometimes (frequently enough)

delta for syscall: 1937450129-1937469011: 18882 cycles = 7.867500 us
delta for syscall: 1956633332-1956654248: 20916 cycles = 8.715000 us
delta for syscall: 1995042065-1995061703: 19638 cycles = 8.182500 us
delta for syscall: 2014239488-2014257992: 18504 cycles = 7.710000 us
delta for syscall: 2016294674-2016316202: 21528 cycles = 8.970000 us
delta for syscall: 2054518259-2054537447: 19188 cycles = 7.995000 us
delta for syscall: 2071839668-2071857146: 17478 cycles = 7.282500 us

But there is even following sometimes:

delta for syscall: 3271734859-3271872037: 137178 cycles = 57.157501 us

Queue of the non-blocking socket is being kept full by another host
which sends udp with 40k chunks per socket write.

Reading /dev/zero in chunks of 50 bytes ends up with about 190
nanosecond on that machine.

-- 
	Evgeniy Polyakov
