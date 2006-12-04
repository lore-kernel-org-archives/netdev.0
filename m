From: Paul Collins <paul@briny.ondioline.org>
Subject: Re: NETDEV-BCM43XX BUG - Failure to associate AP with latest devscape git pull..
Date: Mon, 04 Dec 2006 21:30:15 +1300
Message-ID: <87y7pogj1k.fsf@briny.internal.ondioline.org>
References: <45733FBF.5020800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from jenny.ondioline.org ([66.220.1.122]:57870 "EHLO
	jenny.ondioline.org") by vger.kernel.org with ESMTP
	id S1759268AbWLDIgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 03:36:17 -0500
To: Robert Martin <robertm83@gmail.com>
In-Reply-To: <45733FBF.5020800@gmail.com> (Robert Martin's message of "Sun\, 03
	Dec 2006 16\:21\:03 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Martin <robertm83@gmail.com> writes:

> I seem to be having a problem associating with my AP--everything
> appears fine and I can bring my wireless adapter up (the LED lights up
> correctly), and I don't see complaints about firmware/IRQs in the
> dmesg output.  I am able to see operating APs with an "iwlist wlan0
> scan", but I am unable to connect to the AP, with or without WEP
> encryption enabled (tried none, hex and ascii; nothing worked).  This
> is with the latest wireless-dev pull and a vanilla 2.6.19 kernel with
> "irqpoll" option enabled, otherwise it misbehaves.  I would be happy
> to give more information if requested, or try different
> kernel/firmware options.

I started playing with wireless-dev's bcm43xx-d80211 recently and
noticed that I had to set the frequency manually.  When I did that,
setting the ap manually caused the card to associate immediately.

Here's the sequence of commands I run.  (The driver seems stable on my
hardware, so I've only had to do this twice in the last week, and then
only for reasons unrelated to the driver.)

 ip link set up wlan0
 iwlist wlan0 scan
 iwconfig wlan0 essid $essid key $wep_key
 iwconfig wlan0
(note frequencies differ)
 iwconfig wlan0 freq $freq_from_iwlist_scan
 iwconfig wlan0 ap $ap_mac_address
 dhclient wlan0


-- 
Paul Collins
Wellington, New Zealand

Dag vijandelijk luchtschip de huismeester is dood
