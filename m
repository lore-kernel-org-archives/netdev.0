From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx-softmac: Further improvement in	wireless	statistics
Date: Thu, 13 Jul 2006 23:32:26 -0500
Message-ID: <44B71E5A.3000905@lwfinger.net>
References: <44B3CC25.7060305@lwfinger.net> <1152646370.27683.2.camel@localhost.localdomain> <44B474AF.6010907@lwfinger.net> <1152848265.2584.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:45727 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1161257AbWGNEcb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 00:32:31 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1152848265.2584.48.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> 
> Jean, what's the official word on range->max_qual.level?
> 
> I don't know where I came up with the requirement that max_qual.level
> must be 0 to indicate that the units are in dBm (as opposed to RSSI),
> but it might well have been because we had no way to detect RSSI vs. dBm
> before IW_QUAL_DBM was added as a flag in WE-19, and therefore using
> level = 0 was the only reliable way because 0 is the theoretical "max"
> level that most cards can handle.
> 
> So if you want to express your quality in dBm, you have a choice; either
> set IW_QUAL_DBM explicitly and do what you want with max_qual.level, or
> set your max_qual.level to 0.  That's my interpretation, of course I
> could be wrong.
> 
> Furthermore, there's no point to setting your max_qual.level to be the
> lowest level, since that's what your max_qual.noise is!!!
> max_qual.noise is the noise floor of your card and that effectively _is_
> the lowest level at which your card can operate.
> 
> In the ideal world, which we are now much closer to, we could _require_
> that IW_QUAL_DBM was set, otherwise values would be interpreted as RSSI.
> And we can if the driver's we_source_version is >= 19.  I agree, it's
> all quite confusing for starters.

Setting IW_QUAL_DBM when updating does make /proc/net/wireless report level and noise as negative 
numbers. Thanks for pointing me in that direction.

I also tried both 0 and -100 as the qual_max values. The range is definitely better with -100 than 
with 0.

Larry

