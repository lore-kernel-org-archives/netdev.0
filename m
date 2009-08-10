From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [evb] Re: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Mon, 10 Aug 2009 18:16:08 +0200
Message-ID: <200908101816.08287.arnd@arndb.de>
References: <0199E0D51A61344794750DC57738F58E67D2DCECBB@GVW1118EXC.americas.hpqcorp.net> <200908101723.10832.arnd@arndb.de> <0199E0D51A61344794750DC57738F58E6D6AE99867@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "evb@yahoogroups.com" <evb@yahoogroups.com>,
	"'Stephen Hemminger'" <shemminger@linux-foundation.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"'Or Gerlitz'" <ogerlitz@voltaire.com>,
	"Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>
To: "Fischer, Anna" <anna.fischer@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:63971 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755473AbZHJQQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 12:16:58 -0400
In-Reply-To: <0199E0D51A61344794750DC57738F58E6D6AE99867@GVW1118EXC.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 10 August 2009, Fischer, Anna wrote:
> On the VEPA filtering service side, the only change we have implemented
> in the bridging code is that in VEPA mode all frames are passed to the
> uplink on TX. However, frames are still passed through the netfilter 
> hooks before they go out on the wire. On the inbound path, there are
> no changes to the way frames are processed (except the filtering for
> the original source port), so netfilter hooks work in the same way
> as for a normal bridge.

Ah, interesting. I did not realize that the hooks were still active,
although that obviously makes sense. So that would be another
important difference between our implementations.

> If a frame is reflected back because of a hairpin turn, then of course
> the incoming port is the VEPA uplink port and not the port that
> originally sent the frame. So if you are trying to enforce some
> packet filtering on that inbound path, then you would have to do that
> based on MAC addresses and not on bridge ports. But I would assume that
> you would enforce the filtering already before you send out the frame
> to the adjacent bridge. Apart from that, if you enable your bridge to
> behave in VEPA mode, then you would typically do packet filtering etc
> on the adjacent bridge and not use the netfilter hook. You can still use
> both though, if you like.

Right, that was my point. They bridge in VEPA mode would likely be
configured to be completely ignorant of the data going through it
and not do any filter, and you do all filterring on the adjacent
bridge.

I just wasn't sure that this is possible with ebtables if the
adjacent bridge is a Linux system with the bridge in hairpin turn
mode.

	Arnd <><
