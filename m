From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 1/2] d80211: Add software RTS support
Date: Mon, 5 Feb 2007 18:47:00 +0100
Message-ID: <200702051847.00737.mb@bu3sch.de>
References: <200701312016.50524.IvDoorn@gmail.com> <20070205182808.2209ad3f@griffin.suse.cz> <200702051843.20802.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Michael Buesch <mbuesch@freenet.de>,
	Johannes Berg <johannes@sipsolutions.net>
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:40080
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbXBERrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 12:47:08 -0500
In-Reply-To: <200702051843.20802.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 February 2007 18:43, Ivo van Doorn wrote:
> On Monday 05 February 2007 18:28, Jiri Benc wrote:
> > On Wed, 31 Jan 2007 20:16:50 +0100, Ivo van Doorn wrote:
> > > Not all hardware are capable of generating their own RTS frames.
> > > This patch will add support for creating the RTS frame in software,
> > > when the driver requests this through the flag
> > > IEEE80211_HW_SOFTWARE_RTS
> > 
> > It seems this is not the ideal solution. Most of drivers needing
> > software RTS would need to remember the RTS frame somewhere (as they
> > need to pass it together with the actual frame).
> 
> Well in case of rt2x00 (I am not sure which other drivers also need software RTS)
> the rts packet is just inserted inside the packet ring and is treated as a regular
> packet/fragment that has just been inserted by the driver.
> 
> This patch just adds this additional packet just before the real packet, and in case
> the real packet could not be send the rts packet is stored in the
> ieee80211_tx_stored_packet structure to be send later.

Ok, I see. But this is not going to work with bcm43xx.

I also sent a fix for rt2x00 to work with my patchset.

> > A better solution would be either to pass a pointer to RTS frame data
> > in tx_control or to create a function returning RTS frame.
> 
> In case of rt2x00 this would deliver more problems, especially since it will use
> a ring entry to send the rts frame and in case of rt2500usb and rt73usb it will
> need a sk_buff structure since it needs to pass it to the device (where the sk_buff
> will have some free tx_header_room for the descriptor.)

I don't understand this.
You need to put in into the ring either way.

See my patch.

-- 
Greetings Michael.
