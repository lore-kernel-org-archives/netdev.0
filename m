From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] sctp: Rework the tsn map to use generic
 bitmap.
Date: Wed, 08 Oct 2008 14:19:08 -0700 (PDT)
Message-ID: <20081008.141908.230868244.davem@davemloft.net>
References: <1223497670-519-1-git-send-email-vladislav.yasevich@hp.com>
	<1223497670-519-2-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45002
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754285AbYJHVTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 17:19:32 -0400
In-Reply-To: <1223497670-519-2-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed,  8 Oct 2008 16:27:49 -0400

> The tsn map currently use is 4K large and is stuck inside
> the sctp_association structure making memory references REALLY
> expensive.  What we really need is at most 4K worth of bits
> so the biggest map we would have is 512 bytes.   Also, the
> map is only really usefull when we have gaps to store and
> report.  As such, starting with minimal map of say 32 TSNs (bits)
> should be enough for normal low-loss operations.  We can grow
> the map by some multiple of 32 along with some extra room any
> time we receive the TSN which would put us outside of the map
> boundry.  As we close gaps, we can shift the map to rebase
> it on the latest TSN we've seen.  This saves 4088 bytes per
> association just in the map alone along savings from the now
> unnecessary structure members.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
