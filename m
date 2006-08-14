From: Dan Williams <dcbw@redhat.com>
Subject: Re: network manager confused with bcm43xx-d80211?
Date: Mon, 14 Aug 2006 07:46:51 -0400
Message-ID: <1155556011.2885.3.camel@localhost.localdomain>
References: <44E02F41.2060300@sipsolutions.net>
	 <44E031D2.8070106@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mbuesch@freenet.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41354 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1752008AbWHNLpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 07:45:40 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <44E031D2.8070106@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-08-14 at 10:18 +0200, Johannes Berg wrote:
> For whatever reason, nm always thinks that my default wlan0 device is a 
> *wired* device. I do wonder where the bug is, but couldn't pinpoint it 
> yet, any ideas? mm version is 0.6.3. I'd have thought it would go by the 
> presence of wireless extensions, but if so it uses some call to detect 
> it that isn't implemented here...

No, it asks HAL what the device type is actually.  HAL looks for the
interface in /proc/net/wireless currently, and if it's not there, says
the device is wired.  Run 'lshal', look for your wlan device, and see if
info.capabilities includes 'net.80211'.

So if the wlanX interface isn't in /proc/net/wireless, you lose.  I
think we discussed this in the private rt2x00 thread about a month ago?
Some patches came out of that one, specifically the SET_NETDEV_DEV ones
for rt2x00 and d80211.  The problem with d80211 was that it didn't
implement the get_wireless_stats() handler function, and that function
(I think?) is the one that lets the wlanX device show up
in /proc/net/wireless.

Dan


