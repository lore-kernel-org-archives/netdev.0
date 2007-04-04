From: jamal <hadi@cyberus.ca>
Subject: Re: one more... iproute commands lockup whole system
Date: Wed, 04 Apr 2007 09:58:22 -0400
Message-ID: <1175695102.4063.4.camel@localhost>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>
	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>
	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb>
	 <1175649016.3957.10.camel@localhost> <461301C0.2050409@trash.net>
	 <20070404020622.M69215@visp.net.lb> <1175684114.4088.12.camel@localhost>
	 <4613A9F6.8000307@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys <denys@visp.net.lb>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:1154 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753845AbXDDN6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 09:58:25 -0400
Received: by wx-out-0506.google.com with SMTP id h31so229918wxd
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2007 06:58:25 -0700 (PDT)
In-Reply-To: <4613A9F6.8000307@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-04 at 15:36 +0200, Patrick McHardy wrote:

> 
> We have a loop counter (RTTL) in tc_verd. For some reason it is reset
> after ing_filter though.
> 

Essentially it is valuable just to avoid a lot of stacking (separate
issue) and not to avoid the locking issue he is seeing.


> It would be interesting to find out what the problem is exactly.
> The configuration itself looks harmless, so I'm guessing its
> rather a deadlock than a loop.

We know it is a deadlock. 
If you redirect the first time queue lock for eth0 will be held, before
it is released if you do another redirect, it will again be heading
towards eth0 and it will deadlock on grabbing the queue lock.

cheers,
jamal

