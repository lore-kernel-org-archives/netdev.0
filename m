From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: mv643xx_eth: reclaim TX skbs only when released by
 the HW
Date: Wed, 05 Nov 2014 07:41:15 -0800
Message-ID: <1415202075.12206.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415197979-1702-1-git-send-email-karl.beldan@gmail.com>
	 <545A3838.3090606@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karl Beldan <karl.beldan@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ian Campbell <ijc@hellion.org.uk>,
	Karl Beldan <karl.beldan@rivierawaves.com>,
	netdev@vger.kernel.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:48184 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbaKEPlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 10:41:18 -0500
Received: by mail-ig0-f180.google.com with SMTP id h3so1600451igd.1
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 07:41:17 -0800 (PST)
In-Reply-To: <545A3838.3090606@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-05 at 11:46 -0300, Ezequiel Garcia wrote:
> Hi Karl,
> 
> On 11/05/2014 11:32 AM, Karl Beldan wrote:> From: Karl Beldan <karl.beldan@rivierawaves.com>
> > 
> > ATM, txq_reclaim will dequeue and free an skb for each tx desc released
> > by the hw that has TX_LAST_DESC set. However, in case of TSO, each
> > hw desc embedding the last part of a segment has TX_LAST_DESC set,
> > losing the one-to-one 'last skb frag'/'TX_LAST_DESC set' correspondance,
> > which causes data corruption.
> > 
> > Fix this by checking TX_ENABLE_INTERRUPT instead of TX_LAST_DESC, and
> > warn when trying to dequeue from an empty txq (which can be symptomatic
> > of releasing skbs prematurely).
> > 
> > Fixes: 3ae8f4e0b98 ('net: mv643xx_eth: Implement software TSO')
> 
> Although your change makes sense, this isn't fixing the issue for me,
> neither did the previous one.
> 
> Ian: Can you double check that you have corruption *without* the patch,
> and that the patch fixes the issue?
> 

Have you also applied my patch ?
