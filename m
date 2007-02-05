From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 1/2] d80211: Add software RTS support
Date: Mon, 5 Feb 2007 19:22:46 +0100
Message-ID: <200702051922.46885.mb@bu3sch.de>
References: <200701312016.50524.IvDoorn@gmail.com> <200702051847.00737.mb@bu3sch.de> <200702051907.53220.IvDoorn@gmail.com>
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
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:45749
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932838AbXBESXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 13:23:00 -0500
In-Reply-To: <200702051907.53220.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 February 2007 19:07, Ivo van Doorn wrote:
> Hi,
> 
> > > > > Not all hardware are capable of generating their own RTS frames.
> > > > > This patch will add support for creating the RTS frame in software,
> > > > > when the driver requests this through the flag
> > > > > IEEE80211_HW_SOFTWARE_RTS
> > > > 
> > > > It seems this is not the ideal solution. Most of drivers needing
> > > > software RTS would need to remember the RTS frame somewhere (as they
> > > > need to pass it together with the actual frame).
> > > 
> > > Well in case of rt2x00 (I am not sure which other drivers also need software RTS)
> > > the rts packet is just inserted inside the packet ring and is treated as a regular
> > > packet/fragment that has just been inserted by the driver.
> > > 
> > > This patch just adds this additional packet just before the real packet, and in case
> > > the real packet could not be send the rts packet is stored in the
> > > ieee80211_tx_stored_packet structure to be send later.
> > 
> > Ok, I see. But this is not going to work with bcm43xx.
> > 
> > I also sent a fix for rt2x00 to work with my patchset.
> 
> Did you already send that patchset to the netdev list?
> Because I haven't seen a patch series about rts for d80211 yet.

No, linux-wireless@vger.kernel.org

> The new rt2500usb and rt73usb packet ring handling no longer use a DMA buffer
> but instead send the sk_buffer->data pointer to the USB layer.
> The solution as suggested by Jiri could be handled by making sure the rts allocated
> buffer will also have a tx header room as set in the tx_header_room field. But I am not
> sure if that would be a better solution than putting the rts packet in a sk_buffer that is being
> send out just before the real packet...

In my patchset you can put it into anything you like.
I put it into an skb.

-- 
Greetings Michael.
