From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net: dp83640: Fix tx timestamp overflow handling.
Date: Wed, 20 Jan 2016 14:25:45 +0100
Message-ID: <20160120132545.GB2032@netboy>
References: <1453285348-16022-1-git-send-email-manfred.rudigier@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Manfred Rudigier <manfred.rudigier@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37616 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbcATNZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 08:25:49 -0500
Received: by mail-wm0-f46.google.com with SMTP id n5so29208446wmn.0
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 05:25:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1453285348-16022-1-git-send-email-manfred.rudigier@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2016 at 11:22:28AM +0100, Manfred Rudigier wrote:
> PHY status frames are not reliable, the PHY may not be able to send them
> during heavy receive traffic. This overflow condition is signaled by the
> PHY in the next status frame, but the driver did not make use of it.
> Instead it always reported wrong tx timestamps to user space after an
> overflow happened because it assigned newly received tx timestamps to old
> packets in the queue.
> 
> This commit fixes this issue by clearing the tx timestamp queue every time
> an overflow happens, so that no timestamps are delivered for overflow
> packets. This way time stamping will continue correctly after an overflow.

Hi Manfred,

Thanks for finding and fixing this bug.

Dave, this patch should also go into stable.

Acked-by: Richard Cochran <richardcochran@gmail.com>
