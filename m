From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Sat, 22 Aug 2015 01:59:40 +0200
Message-ID: <20150821235940.GA20313@electric-eye.fr.zoreil.com>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <1440151756-18165-1-git-send-email-vinschen@redhat.com>
 <20150821193926.GA16437@electric-eye.fr.zoreil.com>
 <20150821220756.GI19683@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>,
	nic_swsd <nic_swsd@realtek.com>
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54943 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbbHVAAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 20:00:14 -0400
Content-Disposition: inline
In-Reply-To: <20150821220756.GI19683@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
> On Aug 21 21:39, Francois Romieu wrote:
[...]
> > The code should propagate failure when both rtl8169_reset_counters and
> > rtl8169_update_counters fail.
> 
> This one I don't understand.  Neither failing to reset the counters nor
> failing to update the counters is fatal for the driver.  So far the
> (unchanged) rtl8169_update_counters doesn't even print a log message,

I wouldn't overestimate the value of log messages vs real status return.
Users can be quite unhappy with default settings that spam their logs
(it isn't a problem in open(), it's marginaly murphy plausible from
a periodic get_stats context).

The driver can't propagate errors from the current get_stats context
where rtl8169_update_counters is used. However it can be done in
open().

> while a failing reset in rtl8169_reset_counters now does.
> 
> Why is that not sufficent?

Because of the same reason(s) why this patch wants to improve things.

It isn't a showstopper.

-- 
Ueimor
