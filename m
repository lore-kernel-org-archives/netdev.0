From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 1/2] d80211: Add software RTS support
Date: Mon, 5 Feb 2007 18:43:20 +0100
Message-ID: <200702051843.20802.IvDoorn@gmail.com>
References: <200701312016.50524.IvDoorn@gmail.com> <20070205182808.2209ad3f@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Michael Buesch <mbuesch@freenet.de>,
	Johannes Berg <johannes@sipsolutions.net>
To: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:28492 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbXBERno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 12:43:44 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1362888uga
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 09:43:42 -0800 (PST)
In-Reply-To: <20070205182808.2209ad3f@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 February 2007 18:28, Jiri Benc wrote:
> On Wed, 31 Jan 2007 20:16:50 +0100, Ivo van Doorn wrote:
> > Not all hardware are capable of generating their own RTS frames.
> > This patch will add support for creating the RTS frame in software,
> > when the driver requests this through the flag
> > IEEE80211_HW_SOFTWARE_RTS
> 
> It seems this is not the ideal solution. Most of drivers needing
> software RTS would need to remember the RTS frame somewhere (as they
> need to pass it together with the actual frame).

Well in case of rt2x00 (I am not sure which other drivers also need software RTS)
the rts packet is just inserted inside the packet ring and is treated as a regular
packet/fragment that has just been inserted by the driver.

This patch just adds this additional packet just before the real packet, and in case
the real packet could not be send the rts packet is stored in the
ieee80211_tx_stored_packet structure to be send later.

> A better solution would be either to pass a pointer to RTS frame data
> in tx_control or to create a function returning RTS frame.

In case of rt2x00 this would deliver more problems, especially since it will use
a ring entry to send the rts frame and in case of rt2500usb and rt73usb it will
need a sk_buff structure since it needs to pass it to the device (where the sk_buff
will have some free tx_header_room for the descriptor.)

Ivo
