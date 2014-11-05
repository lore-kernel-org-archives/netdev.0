From: Ian Campbell <ijc@hellion.org.uk>
Subject: Re: [PATCH] net: mv643xx_eth: reclaim TX skbs only when released by
 the HW
Date: Wed, 05 Nov 2014 19:04:15 +0000
Message-ID: <1415214255.31613.9.camel@hellion.org.uk>
References: <1415197979-1702-1-git-send-email-karl.beldan@gmail.com>
	 <545A3838.3090606@free-electrons.com>
	 <1415202075.12206.0.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Karl Beldan <karl.beldan@gmail.com>,
	David Miller <davem@davemloft.net>,
	Karl Beldan <karl.beldan@rivierawaves.com>,
	netdev@vger.kernel.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from benson.vm.bytemark.co.uk ([212.110.190.137]:50609 "EHLO
	benson.vm.bytemark.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbaKETEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 14:04:21 -0500
In-Reply-To: <1415202075.12206.0.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-05 at 07:41 -0800, Eric Dumazet wrote:
> On Wed, 2014-11-05 at 11:46 -0300, Ezequiel Garcia wrote:
> > Hi Karl,
> > 
> > On 11/05/2014 11:32 AM, Karl Beldan wrote:> From: Karl Beldan <karl.beldan@rivierawaves.com>
> > > 
> > > ATM, txq_reclaim will dequeue and free an skb for each tx desc released
> > > by the hw that has TX_LAST_DESC set. However, in case of TSO, each
> > > hw desc embedding the last part of a segment has TX_LAST_DESC set,
> > > losing the one-to-one 'last skb frag'/'TX_LAST_DESC set' correspondance,
> > > which causes data corruption.
> > > 
> > > Fix this by checking TX_ENABLE_INTERRUPT instead of TX_LAST_DESC, and
> > > warn when trying to dequeue from an empty txq (which can be symptomatic
> > > of releasing skbs prematurely).
> > > 
> > > Fixes: 3ae8f4e0b98 ('net: mv643xx_eth: Implement software TSO')
> > 
> > Although your change makes sense, this isn't fixing the issue for me,
> > neither did the previous one.
> > 
> > Ian: Can you double check that you have corruption *without* the patch,
> > and that the patch fixes the issue?

Yes, doing md5sum on an NFS mount with 18 files in it I see 8-9
corrupted ones without any patch applied and none with Karl's previous
one from <20141104142020.GA6728@magnum.frso.rivierawaves.com> in place.

This was consistent over repeated invocations of md5sum (mounting and
unmounting around each one).

I've just confirmed this again to be sure.

The system is a QNAP TS-41x (armel, Feroceon 88FR131)

> Have you also applied my patch ?

I've only applied that one patch from Karl onto the 3.16.7 kernel which
is currently in Debian. Debian hasn't got any other mv643xx patches
applied.

I'm building now with Karl's latest patch from
<1415197979-1702-1-git-send-email-karl.beldan@gmail.com> instead.

Ian.
