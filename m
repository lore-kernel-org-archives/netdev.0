From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Who's allowed to set a skb destructor?
Date: Thu, 5 Jul 2007 15:06:40 +0200
Message-ID: <20070705130640.GA24731@one.firstfloor.org>
References: <p733b032mec.fsf@bingen.suse.de> <20070705122849.GA4759@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Brice Goglin <Brice.Goglin@ens-lyon.org>,
	netdev@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Divy Le Ray <divy@chelsio.com>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46186 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757782AbXGENGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 09:06:44 -0400
Content-Disposition: inline
In-Reply-To: <20070705122849.GA4759@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 05, 2007 at 02:28:50PM +0200, Jarek Poplawski wrote:
> I wonder if it's very unsound to think about a one way list
> of destructors. Of course, not owners could only clean their
> private allocations. Woudn't this save some skb clonning,
> copying or adding new fields for private infos?

skb cloning isn't very expensive when you need it. And they
got a little private area you can use for your own stuff 
while you have it queued (skb->cb) 

As a historical note one of the big changes during the Linux 2.0
and 2.1 TCP rewrite was that TCP was changed to always clone for the
retransmit queue. This cleaned up the code greatly and fixed
many problems. Cloning was also especially optimized for this. When TCP 
which is about one of the most performance critical protocols around can 
afford it likely other code can too.

-Andi
