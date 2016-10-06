From: michael-dev <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Subject: Re: [PATCH 3/3] mac80211: multicast to unicast conversion
Date: Thu, 06 Oct 2016 13:53:08 +0200
Message-ID: <199ae52e4e3000456d8d65b81500d874@fami-braun.de>
References: <1475643324-2845-1-git-send-email-michael-dev@fami-braun.de>
 <1475643324-2845-3-git-send-email-michael-dev@fami-braun.de>
 <1475662791.4994.39.camel@sipsolutions.net>
 <1690671fb30f19c53c7883a5207c5721@fami-braun.de>
 <1475668688.4994.46.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, projekt-wlan-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475668688.4994.46.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am 05.10.2016 13:58, schrieb Johannes Berg:
> 
> Anyway, perhaps this needs to change to take DMS/per-station into
> account?
> 
> Then again, this kind of setting - global multicast-to-unicast -
> fundamentally *cannot* be done on a per-station basis, since if you
> enable it for one station and not for another, the first station that
> has it enabled would get the packets twice...

as I see it, that is exactly how DMS is standarized.

IEEE 802.11-2012 section 10.23.15 DMS procedures:

"If the requested DMS is accepted by the AP, the AP shall send 
subsequent group addressed MSDUs that
match the frame classifier specified in the DMS Descriptors to the 
requesting STA as A-MSDU subframes
within an individually addressed A-MSDU frame (see 8.3.2.2 and 9.11)."

  -> so the multicast packets shall go out as unicast A-MSDU frames to 
stations that requested this

"The AP shall continue to transmit the matching frames as group 
addressed frames (see 9.3.6, and 10.2.1.16) if at least one associated 
STA has not requested DMS for these frames."

  -> so it will continue to send it as multicast frames as well.

As with DMS the station requested DMS for a specific multicast address, 
it could then drop multicast frames addressed to the multicast address 
it registered for DMS.

Regards,
M. Braun
