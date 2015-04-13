From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Mon, 13 Apr 2015 16:16:38 -0400 (EDT)
Message-ID: <20150413.161638.1169173491693514924.davem@davemloft.net>
References: <1428704189-31247-1-git-send-email-fw@strlen.de>
	<20150413.135348.461869719021663434.davem@davemloft.net>
	<1428950452.3833058.253180861.49ADF43A@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, kaber@trash.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754385AbbDMUQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 16:16:42 -0400
In-Reply-To: <1428950452.3833058.253180861.49ADF43A@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 13 Apr 2015 20:40:52 +0200

> netfilter does alter the skbs destructiveley. So the only reason we
> could use those unaltered skbs would be to save the lengths of the
> individual fragments so we could reapply them to the altered
> (constructed by reassembly) one in the output path. This seems much more
> complex to me. :/

It could process the individual fragments one by one then.  Then
at the end you could see what the final verdicts look like.

What happens right now is so damn expensive, has the geometry
issue, and is totally unnecessary %99.99999 of the time.

I therefore think there is massive value in trying to make it work to
keep the original frags around as a group and try to process them that
way.
