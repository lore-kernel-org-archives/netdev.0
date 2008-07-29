From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC][PATCH 1/1] net: support for hardware timestamping
Date: Tue, 29 Jul 2008 08:54:57 -0700
Message-ID: <20080729085457.033a9fd2@extreme>
References: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com>
	<1217290080-4251-2-git-send-email-opurdila@ixiacom.com>
	<1217343163.30512.34.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:38661 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751612AbYG2Py7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 11:54:59 -0400
In-Reply-To: <1217343163.30512.34.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Jul 2008 16:52:43 +0200
Patrick Ohly <patrick.ohly@intel.com> wrote:

> On Tue, 2008-07-29 at 03:08 +0300, Octavian Purdila wrote:
> > New socket option and socket control message are added as well
> > (SO_TIMESTAMPHW and SCM_TIMESTAMPHW).
> 
> How is a network driver notified that it is expected to do hardware time
> stamping? The connection between the socket option and the driver isn't
> quite clear to me (which might very well be due to my lack of experience
> in this area - please bear with me...). Is the driver expected to check
> the socket flags whenever it gets a chance?
> 
> IMHO it would be necessary to attach this configuration change not just
> to a socket, but also to a message which is then routed to the right
> device driver.
>
In my sky2 sample code, I took a different approach:
 1. Why have HW timestamps different than existing timestamps? If you
    just use existing timestamp, no socket API is needed.
 2. Driver can periodically check if socket timestamping is enabled,
    (atomic_read(&netstamp_needed)) and enable hardware stamping then.
    Alternatively, add a new notifier to net_enable_timestamp() and
    net_disable_timestamp().


   
