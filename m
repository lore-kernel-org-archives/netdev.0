From: David Miller <davem@davemloft.net>
Subject: Re: async network I/O, event channels, etc
Date: Thu, 27 Jul 2006 01:20:37 -0700 (PDT)
Message-ID: <20060727.012037.78156999.davem@davemloft.net>
References: <20060727.010255.87351515.davem@davemloft.net>
	<20060727080901.GG5282@suse.de>
	<20060727081114.GH5282@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, drepper@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32415
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750762AbWG0IUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 04:20:18 -0400
To: axboe@suse.de
In-Reply-To: <20060727081114.GH5282@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jens Axboe <axboe@suse.de>
Date: Thu, 27 Jul 2006 10:11:15 +0200

> Ownership transition from user -> kernel that is, what I'm trying to say
> that returning ownership to the user again is the tricky part.

Yes, it is important that for TCP, for example, we don't give
the user the event until the data is acknowledged and the skb's
referencing that data are fully freed.

This is further complicated by the fact that packetization boundaries
are going to be different from AIO buffer boundaries.

I think this is what you are alluding to.
