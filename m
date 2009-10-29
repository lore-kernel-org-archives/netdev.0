From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] multiqueue changes
Date: Thu, 29 Oct 2009 22:15:43 +0100
Message-ID: <20091029211543.GA3036@ami.dom.local>
References: <4ACD9255.4020008@gmail.com>
 <20091008090344.GA7409@ff.dom.local>
 <20091008120039.GA8691@ff.dom.local>
 <4AE87EEE.4020703@trash.net>
 <20091028212337.GA3218@ami.dom.local>
 <4AE9C4C3.9040503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:39186 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755633AbZJ2VPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 17:15:44 -0400
Received: by bwz27 with SMTP id 27so2816595bwz.21
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2009 14:15:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AE9C4C3.9040503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2009 at 05:37:23PM +0100, Patrick McHardy wrote:
...
> Well, we do need both values for supporting changes to the actually
> used numbers of TX queues. If I understood Dave's explanation correctly,
> this is also what's intended. It also doesn't seem unreasonable
> what bnx2 is doing.

Exactly. With a growing number of cores, both available and powered
off, these values will be soon treated more carefully than now.

> But getting back to the problem Eric reported - so you're suggesting
> that bnx2.c should also adjust num_tx_queues in case the hardware
> doesn't support multiqueue? That seems reasonable as well.

Currently, declaring num_tx_queues with alloc_netdev_mq() looks like
too soon for some drivers. It seems they should be able to do it
separately later during the .probe. There is a question if .ndo_open
should be considered too.

Jarek P.
