From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/1] mv643xx_eth: Disable TSO by default
Date: Sat, 01 Nov 2014 11:01:08 -0700
Message-ID: <1414864868.31792.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>
	 <1414862766.31792.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141101183300.0c04125d@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:61744 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758317AbaKASBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 14:01:11 -0400
Received: by mail-ig0-f172.google.com with SMTP id a13so2670233igq.5
        for <netdev@vger.kernel.org>; Sat, 01 Nov 2014 11:01:10 -0700 (PDT)
In-Reply-To: <20141101183300.0c04125d@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-11-01 at 18:33 +0100, Thomas Petazzoni wrote:
> Dear Eric Dumazet,

You can call me Eric ;)

> As far as I know, ARMv5 does not do out-of-order execution, and so on
> ARMv5, mb() == rmb() == wmb() == barrier(). But might be a missing
> compiler barrier, indeed, as that's not specific to the architecture.
> 
> Thanks for the hint!

I think the wmb() is needed, but the more worrying problem is the NIC
can start transmitting a segment while the data payload is not yet
placed in TX descriptor.

Normally, the patch I cooked should avoid this.
