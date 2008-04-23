From: Markus Brunner <super.firetwister@googlemail.com>
Subject: Re: Phy read timeout in ibm_new_emac driver
Date: Wed, 23 Apr 2008 07:06:31 +0200
Message-ID: <200804230706.32641.super.firetwister@gmail.com>
References: <6a6049b80804160349q42120b4bs1c0db49ea5ad055d@mail.gmail.com> <1208347791.6958.279.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ppc-dev <linuxppc-dev@ozlabs.org>
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:45750 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbYDWFFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 01:05:38 -0400
Received: by ug-out-1314.google.com with SMTP id z38so350478ugc.16
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 22:05:36 -0700 (PDT)
In-Reply-To: <1208347791.6958.279.camel@pasglop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 16 April 2008, Benjamin Herrenschmidt wrote:

> Somebody knows off hand what the standard says the timeout should be ?

Anyone?

I didn't find any documentation on the standard, but I had a look at other 
drivers. 
au1000_eth.c waits 20 ms (20 * 1ms) in mdio_read.
bfin_mac.c waits 500 * 1us in mdio_poll. 
In both functions the last delay before the timeout is useless, like in 
new_emac. Not nice, but timeouts shouldn't occur anyway.

new emac probably doesn't wait long enough, but 20ms seems to be a bit too 
long.

Regards
Markus
