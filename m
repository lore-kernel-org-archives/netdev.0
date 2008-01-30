From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: Compex FreedomLine 32 PnP-PCI2 broken with de2104x
Date: Wed, 30 Jan 2008 21:23:06 +0100
Message-ID: <200801302123.07783.linux@rainbow-software.org>
References: <200801262158.12016.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.gsystems.sk ([62.176.172.50]:38275 "EHLO www.gsystems.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756990AbYA3UXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:23:12 -0500
In-Reply-To: <200801262158.12016.linux@rainbow-software.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 26 January 2008 21:58:10 Ondrej Zary wrote:
> Hello,
> I was having problems with these FreedomLine cards with Linux before but
> tested it thoroughly today. This card uses DEC 21041 chip and has TP and
> BNC connectors:
>
> 00:12.0 Ethernet controller [0200]: Digital Equipment Corporation DECchip
> 21041 [Tulip Pass 3] [1011:0014] (rev 21)
>
>
> de2104x driver was loaded automatically by udev and card seemed to work.
> Until I disconnected the TP cable and putting it back after a while. The
> driver then switched to (non-existing) AUI port and remained there. I tried
> to set media to TP using ethtool - and the whole kernel crashed because of
> BUG_ON(de_is_running(de));
> in de_set_media(). Seems that the driver is unable to stop the DMA in
> de_stop_rxtx().
>
> I commented out AUI detection in the driver - this time it switched to BNC
> after unplugging the cable and remained there. I also attempted to reset
> the chip when de_stop_rxtx failed but failed to do it.
>
> Then I found that there's de4x5 driver which supports the same cards as
> de2104x (and some other too) - and this one works fine! I can plug and
> unplug the cable and even change between TP and BNC ports just by
> unplugging one and plugging the other cable in. Unfortunately, this driver
> is blacklisted by default - at least in Slackware and Debian.
>
> The question is: why does de2104x exist? Does it work better with some
> hardware?
>
> BTW. Found that the problem exist at least since 2003:
> http://oss.sgi.com/archives/netdev/2003-08/msg00951.html

Does the de2104x driver work correctly for anyone?

-- 
Ondrej Zary
