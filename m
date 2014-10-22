From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix saving TX flow hash in sock for outgoing
 connections
Date: Wed, 22 Oct 2014 12:09:56 -0700
Message-ID: <1414004996.9031.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413994321-20435-1-git-send-email-sathya.perla@emulex.com>
	 <1413999542.9031.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CF9D1877D81D214CB0CA0669EFAE020C68CA2FAA@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>
To: Sathya Perla <Sathya.Perla@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:54443 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174AbaJVTJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 15:09:58 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so2296847pab.0
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 12:09:57 -0700 (PDT)
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C68CA2FAA@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-22 at 18:35 +0000, Sathya Perla wrote:
> > -----Original Message-----
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]

> > 
> > Are you really using the socket/flow hash to select a TXQ ?
> Yes, as I don't have XPS configured on my setup.
> netdev_pick_tx() uses the socket/flow hash when XPS is not used.

Yes, this is the (poor) fallback

> 
> > 
> > Even with this patch, you have a good probability of multiple
> > cpus hitting same TXQ.
> Agree. Are you suggesting that drivers should automatically
> register an XPS configuration? I thought it was upto the user
> to enable it...

Yep, search for netif_set_xps_queue()

(commit 537c00de1c9ba9876b9)

Look at commit d03a68f8217ea0349 for an example of how it can be done,
if user do not override this later.
