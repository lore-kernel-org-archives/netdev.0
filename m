From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Thu, 26 Dec 2013 10:17:41 +0100
Message-ID: <20131226091740.GA8787@netboy>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com>
 <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com>
 <52B6E568.4030400@mellanox.com>
 <20131223184845.GA4922@netboy>
 <52B992EE.5030401@mellanox.com>
 <20131225115322.GB5378@netboy>
 <52BBE84C.1030702@mellanox.com>
 <52BBE9D6.3040006@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tomk@rgmadvisors.com" <tomk@rgmadvisors.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:47545 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792Ab3LZJRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 04:17:55 -0500
Received: by mail-ea0-f180.google.com with SMTP id f15so3608664eak.39
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 01:17:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52BBE9D6.3040006@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 26, 2013 at 10:33:26AM +0200, Hadar Hen Zion wrote:
> 
> Is there a way to time stamping packets per socket?

No, it is at the device level. Some devices support time stamping
different types of packets, like PTP events.

I looked again at your driver, and now it makes sense to me that the
spin lock is so costly in your tests. Every received packet calls
timecounter_cyc2time.  So you will need locking, and I think
reader/writer is perfectly fine for you to use.

Thanks,
Richard
