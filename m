From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 3/3] mac80211: multicast to unicast conversion
Date: Thu, 06 Oct 2016 13:55:09 +0200
Message-ID: <1475754909.2015.15.camel@sipsolutions.net>
References: <1475643324-2845-1-git-send-email-michael-dev@fami-braun.de>
         <1475643324-2845-3-git-send-email-michael-dev@fami-braun.de>
         <1475662791.4994.39.camel@sipsolutions.net>
         <1690671fb30f19c53c7883a5207c5721@fami-braun.de>
         <1475668688.4994.46.camel@sipsolutions.net>
         <199ae52e4e3000456d8d65b81500d874@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, projekt-wlan@fem.tu-ilmenau.de,
        netdev <netdev@vger.kernel.org>
To: michael-dev <michael-dev@fami-braun.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:54724 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752512AbcJFLzO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Oct 2016 07:55:14 -0400
In-Reply-To: <199ae52e4e3000456d8d65b81500d874@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-06 at 13:53 +0200, michael-dev wrote:
> Am 05.10.2016 13:58, schrieb Johannes Berg:
> > 
> > 
> > Anyway, perhaps this needs to change to take DMS/per-station into
> > account?
> > 
> > Then again, this kind of setting - global multicast-to-unicast -
> > fundamentally *cannot* be done on a per-station basis, since if you
> > enable it for one station and not for another, the first station
> > that has it enabled would get the packets twice...
> 
> as I see it, that is exactly how DMS is standarized.
> 
> IEEE 802.11-2012 section 10.23.15 DMS procedures:
> 
> "If the requested DMS is accepted by the AP, the AP shall send 
> subsequent group addressed MSDUs that
> match the frame classifier specified in the DMS Descriptors to the 
> requesting STA as A-MSDU subframes
> within an individually addressed A-MSDU frame (see 8.3.2.2 and
> 9.11)."
> 
>   -> so the multicast packets shall go out as unicast A-MSDU frames
> to  stations that requested this

Correct.

> "The AP shall continue to transmit the matching frames as group 
> addressed frames (see 9.3.6, and 10.2.1.16) if at least one
> associated 
> STA has not requested DMS for these frames."
> 
>   -> so it will continue to send it as multicast frames as well.
> 
> As with DMS the station requested DMS for a specific multicast
> address, it could then drop multicast frames addressed to the
> multicast address it registered for DMS.

Yes, the DMS spec tells it to do this. However, we can't implement non-
DMS similarly, because then the station won't request it and won't drop
the duplicates.

So for this non-standard multicast-to-unicast, it's all or nothing, it
can't be done for some stations only.

johannes
