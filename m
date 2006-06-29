From: Michael Buesch <mb@bu3sch.de>
Subject: Re: bcm43xx: "transmit timed out" and apparent hang with "preemptible periodic work" patches
Date: Thu, 29 Jun 2006 17:49:53 +0200
Message-ID: <200606291749.53858.mb@bu3sch.de>
References: <87ac80ps5o.fsf@briny.internal.ondioline.org> <200606291707.55172.mb@bu3sch.de> <87mzbwvv07.fsf@briny.internal.ondioline.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:47503
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750801AbWF2PuD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 11:50:03 -0400
To: Paul Collins <paul@briny.ondioline.org>
In-Reply-To: <87mzbwvv07.fsf@briny.internal.ondioline.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 29 June 2006 17:31, Paul Collins wrote:
> Michael Buesch <mb@bu3sch.de> writes:
> 
> > On Thursday 29 June 2006 10:24, Paul Collins wrote:
> >> Michael Buesch <mb@bu3sch.de> writes:
> >> 
> >> > On Monday 26 June 2006 14:43, Michael Buesch wrote:
> >> >> Try to get more logs.
> >> >> I suggest to do a netconsole for logging.
> >> >
> >> > Also note that current softmac trees have a patch missing.
> >> > It seems it got lost somewhere after my merge request.
> >> > I already contacted John in private for this, but no reply, yet.
> >> > The patch is attached. Maybe it fixes your issue.
> >> 
> >> On a preempt kernel I can trigger the hang easily,
> >
> > How? I need to reproduce it to get a clue and fix it. :)
> 
> I did it by running the commands I listed in my previous message.
> Here they are again, minus the pesky log messages.
> 
>   ip set link eth1 up
>   ip set link eth1 down
>   iwconfig eth1 essid wlan-ap enc off
>   ip set link eth1 down
>   ip set link eth1 up
>   iwconfig eth1 essid wlan-ap enc off
>   dhclient eth1

Uh, oh. You are doing an up-down-up cycle here...
I might get a clue now. This reminds me of some thought at yesterday
evening. I think that the up-down-up(down-up....) cycle is
broken and works only by accident mostly.
This bug might be hitting you here.
I will do a careful patch and send it out, later.

-- 
Greetings Michael.
