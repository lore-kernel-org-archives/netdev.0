From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 1/2] d80211: Add software RTS support
Date: Mon, 5 Feb 2007 18:43:06 +0100
Message-ID: <200702051843.07026.mb@bu3sch.de>
References: <200701312016.50524.IvDoorn@gmail.com> <20070205182808.2209ad3f@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ivo van Doorn <ivdoorn@gmail.com>,
	"John Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Michael Buesch <mbuesch@freenet.de>,
	Johannes Berg <johannes@sipsolutions.net>
To: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:39241
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539AbXBERnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 12:43:20 -0500
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
> 
> A better solution would be either to pass a pointer to RTS frame data
> in tx_control or to create a function returning RTS frame.

I sent a patchset that works with most (all?) hardware implementations,
as it uses library calls.

I also think that sending RTS in software is not going to work,
as the timing can not be guaranteed. And timing is why we do it in
the first place. If the HW is not capable of sending RTS frames, we
should not try to emulate them in SW, as it might make the situation
even worse by messing up the NAVs by wrong timing.

-- 
Greetings Michael.
