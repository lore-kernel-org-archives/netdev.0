From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 1/2] d80211: Turn PHYmode list from an array into a linked list
Date: Fri, 15 Dec 2006 14:54:55 +0100
Message-ID: <200612151454.55508.mb@bu3sch.de>
References: <200612141920.11439.mb@bu3sch.de> <20061215144859.49a9c8f3@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:38670
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbWLONzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 08:55:18 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061215144859.49a9c8f3@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 15 December 2006 14:48, Jiri Benc wrote:
> On Thu, 14 Dec 2006 19:20:11 +0100, Michael Buesch wrote:
> > This turns the PHY-modes list into a linked list.
> > The advantage is that drivers can add modes dynamically, as they probe
> > them and don't have to settle to a given arraysize at the beginning
> > of probing.
> 
> ACK.

Thanks. Will submit fixes for the other drivers, too.

> > @@ -198,8 +200,7 @@ static int ieee80211_ioctl_scan(struct n
> >  		param->u.scan.last_rx = local->scan.rx_packets;
> >  		local->scan.rx_packets = -1;
> >  	}
> > -	param->u.scan.channel = local->hw.modes[local->scan.mode_idx].
> > -		channels[local->scan.chan_idx].chan;
> > +	param->u.scan.channel = 
> > local->scan.mode->channels[local->scan.chan_idx].chan;
> >  
> >  	return 0;
> >  }
> 
> The patch is malformed. Fixed and applied to my tree.

I'm sorry. Forgot to remove the "wrap at ~80chars option in my mailer.

Can you also apply the bcm43xx fix for this to your tree?
I think that should be easiest and prevent long-living breakage.

-- 
Greetings Michael.
