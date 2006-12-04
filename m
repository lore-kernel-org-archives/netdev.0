From: Dan Williams <dcbw@redhat.com>
Subject: Re: NETDEV-BCM43XX BUG - Failure to associate AP with latest
	devscape git pull..
Date: Mon, 04 Dec 2006 08:00:52 -0500
Message-ID: <1165237252.2738.5.camel@localhost.localdomain>
References: <45733FBF.5020800@gmail.com>
	 <87y7pogj1k.fsf@briny.internal.ondioline.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Martin <robertm83@gmail.com>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:22702 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1758764AbWLDM65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 07:58:57 -0500
To: Paul Collins <paul@briny.ondioline.org>
In-Reply-To: <87y7pogj1k.fsf@briny.internal.ondioline.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-12-04 at 21:30 +1300, Paul Collins wrote:
> Robert Martin <robertm83@gmail.com> writes:
> 
> > I seem to be having a problem associating with my AP--everything
> > appears fine and I can bring my wireless adapter up (the LED lights up
> > correctly), and I don't see complaints about firmware/IRQs in the
> > dmesg output.  I am able to see operating APs with an "iwlist wlan0
> > scan", but I am unable to connect to the AP, with or without WEP
> > encryption enabled (tried none, hex and ascii; nothing worked).  This
> > is with the latest wireless-dev pull and a vanilla 2.6.19 kernel with
> > "irqpoll" option enabled, otherwise it misbehaves.  I would be happy
> > to give more information if requested, or try different
> > kernel/firmware options.
> 
> I started playing with wireless-dev's bcm43xx-d80211 recently and
> noticed that I had to set the frequency manually.  When I did that,
> setting the ap manually caused the card to associate immediately.

That sounds suspiciously like the driver either doesn't have the correct
scan results to be able to pick the AP's frequency, or is not correctly
searching those scan results to find it...  If the AP is in the scan
list, the driver should definitely be able to find & set the frequency
for the AP, _unless_ you've previously specified a non-zero frequency
for iwconfig ethX freq [1].  Do you see your AP in the 'iwlist wlan0
scan' output?

dan

[1] with WEXT, if you've specified a fixed frequency with iwconfig wlan0
freq XXXX, the driver should stay locked to that frequency until it is
told to unlock with iwconfig wlan0 freq 0.

> Here's the sequence of commands I run.  (The driver seems stable on my
> hardware, so I've only had to do this twice in the last week, and then
> only for reasons unrelated to the driver.)
> 
>  ip link set up wlan0
>  iwlist wlan0 scan
>  iwconfig wlan0 essid $essid key $wep_key
>  iwconfig wlan0
> (note frequencies differ)
>  iwconfig wlan0 freq $freq_from_iwlist_scan
>  iwconfig wlan0 ap $ap_mac_address
>  dhclient wlan0
> 
> 

