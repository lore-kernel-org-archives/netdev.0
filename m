From: Karl Beldan <karl.beldan@gmail.com>
Subject: Re: [PATCH] net: mv643xx_eth: reclaim TX skbs only when released by
 the HW
Date: Wed, 5 Nov 2014 16:05:21 +0100
Message-ID: <20141105150521.GA25354@magnum.frso.rivierawaves.com>
References: <1415197979-1702-1-git-send-email-karl.beldan@gmail.com>
 <545A3838.3090606@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	Ian Campbell <ijc@hellion.org.uk>,
	Karl Beldan <karl.beldan@rivierawaves.com>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:47716 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754590AbaKEPFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 10:05:31 -0500
Received: by mail-wi0-f174.google.com with SMTP id d1so12694052wiv.1
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 07:05:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <545A3838.3090606@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2014 at 11:46:16AM -0300, Ezequiel Garcia wrote:
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
This change fixes a serious issue.
On my side I can now trigger misc NFS and md5sums errors very easily,
which I haven't detected so far with it applied.
Are you running little endian ? Do you have the tso alignment fix
a63ba13e (I don't expect it to be required but I don't know what SoC you
are using) ? I suppose you are running with all 3 fixes applied.
 
Karl
