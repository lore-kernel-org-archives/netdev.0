From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ppp: add 64 bit stats
Date: Wed, 25 Jul 2012 06:04:21 +0200
Message-ID: <1343189061.2626.11073.camel@edumazet-glaptop>
References: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
	 <1343020585.2626.10054.camel@edumazet-glaptop>
	 <CABF+-6WHqzXhvv9etdAqsamZirbWxWJEsnU-CQ1H8tvynCTOZA@mail.gmail.com>
	 <1343059184.2626.11027.camel@edumazet-glaptop>
	 <CABF+-6Vko_T2RCsk1KVouB8a+8Ms_aLEoA-Xet1nxB8bnZAxMA@mail.gmail.com>
	 <1343110954.2626.11040.camel@edumazet-glaptop>
	 <CABF+-6Wpn8yEvru1FDsaFbXYZ7tyeQqqbEU2VY8hLKvmXXFBXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Groeneveld <kgroeneveld@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:46157 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715Ab2GYEE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 00:04:26 -0400
Received: by weyx8 with SMTP id x8so196062wey.19
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 21:04:25 -0700 (PDT)
In-Reply-To: <CABF+-6Wpn8yEvru1FDsaFbXYZ7tyeQqqbEU2VY8hLKvmXXFBXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-24 at 22:27 -0400, Kevin Groeneveld wrote:

> After looking at the existing ppp code more I wonder if I would even
> need to add my own spinlocks.  It seems the only spots I am updating
> the 64 bit stats are already protected by either ppp->wlock or
> ppp->rlock spinlocks.  If I used two separate u64_stats_sync
> structures, one for tx stats and one for rx stats, wouldn't the
> existing spinlocks be enough?

It there are spinlocks already, why even adding u64_stats_sync ?

Just use existing spinlocks to protect your new u64 fields (in the
ngso_get_stats64())
