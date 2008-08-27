From: Andi Kleen <andi@firstfloor.org>
Subject: Re: loaded router, excessive getnstimeofday in oprofile\
Date: Wed, 27 Aug 2008 20:32:16 +0200
Message-ID: <20080827183216.GZ26610@one.firstfloor.org>
References: <200808220457.40892.denys@visp.net.lb> <20080826201406.GA24827@2ka.mipt.ru> <48B46B48.7030609@cosmosbay.com> <20080826205158.GA15266@2ka.mipt.ru> <87vdxmr53f.fsf@basil.nowhere.org> <48B57BD3.5050206@hp.com> <20080827162735.GW26610@one.firstfloor.org> <48B58586.3080806@hp.com> <20080827165635.GY26610@one.firstfloor.org> <48B58E6B.1030302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Rick Jones <rick.jones2@hp.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56460 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbYH0S3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 14:29:44 -0400
Content-Disposition: inline
In-Reply-To: <48B58E6B.1030302@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Doing the expensive timestamping in a possibly delayed thread (ie some 
> milliseconds
> after hardware notification) is wrong/useless.

We had this discussion earlier, please review the thread I linked to. 

Note that interrupts can be arbitarily delayed too (both by cli
and by interrupt mitigation), even on a non RT kernel.

If you want exact notification (packet arriving at your NIC's buffers) you 
need NIC hardware support (and more and more NICs have it[1]). 
If you do it in software then even the interrupt is at the end of a long 
queue with a pretty much arbitary delay. Doing it in socket context is 
just one queue more. It's pretty much all arbitary.

The argument for doing it as late as possible is the prohibitive 
cost on some systems as people notice all the time.

-Andi

[1] Unfortunately not necessarily synchronized with system time.
