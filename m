From: Bastian Bloessl <basti@b-bl.de>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 27 Aug 2008 14:17:16 +0200
Message-ID: <48B545CC.70006@b-bl.de>
References: <20080822120918.GB14981@ff.dom.local>	<20080822121144.GA32397@gondor.apana.org.au>	<20080822.051841.259820995.davem@davemloft.net>	<20080822124556.GA15788@gondor.apana.org.au>	<20080824192639.587f9391@speedy>	<20080824234947.GA19018@gondor.apana.org.au>	<20080824202922.2cc9b9f6@speedy>	<20080826073508.GA1039@gondor.apana.org.au>	<20080826074702.GA1102@gondor.apana.org.au>	<20080826082455.729662ae@speedy>	<20080826124153.GA2732@gondor.apana.org.au> <20080826085029.44a26f56@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org, denys@visp.net.lb,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	jamal <hadi@cyberus.ca>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wp035.webpack.hosteurope.de ([80.237.132.42]:41893 "EHLO
	wp035.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753646AbYH0MRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 08:17:36 -0400
In-Reply-To: <20080826085029.44a26f56@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:

> 
> Last time I tried TBF(100kbit) { netem(+100ms) } it gave different answers
> than netem(+100ms) { TBF(100kbit) }.  

This might be because in the 2nd case you waste tokens when netem 
requeues to TBF.
But TBFs requeue() can't restore tokens because as David said netem uses 
it to enqueue reordered packets.
