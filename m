From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3 + HP iLO2 -> IPv6 broken
Date: Tue, 30 Sep 2008 15:53:34 -0700
Message-ID: <20080930225334.GA735@xw6200.broadcom.net>
References: <gbu10u$uvr$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Bernhard Schmidt" <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1203 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983AbYI3Wxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 18:53:44 -0400
In-Reply-To: <gbu10u$uvr$1@ger.gmane.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2008 at 01:09:02PM -0700, Bernhard Schmidt wrote:
> Hello,
> 
> I have an interesting bug here which I just can't put my finger on.
> 
> I have just bought a HP Proliant DL320 G5p. It features an integrated
> out-of-band controller called iLO2, which shares a physical ethernet
> connection with one of the two BCM5715 GigE ports of the system.
> 
> Basic problem:
> I cannot get native IPv6 to work on the first (shared) GigE port.
> The system does not autoconfigure an address and does not respond to
> incoming neighbor solicitations for it's link-local address. Unless I
> either
> 
> a) reboot the iLO2 by e.g. adjusting anything in the network settings
>    (just switching the "use WINS servers from DHCP reply" is enough to
>    restart it). This fixes my issues up until the next reboot of Linux,
>    which breaks things again
> 
> _OR_
> 
> b) set the port to promiscous mode and leave it set.
> 
> The second GigE port using the same network chip does not have this
> problem.
> 
> Now I think this points to an issue with the iLO2, and indeed HP has
> recently announced version 1.60 of the iLO2 firmware which is supposed
> to fix an issue with dualstacked IPv4/IPv6 operation of the host, but
> this version is installed. And IMHO, if the iLO2 would be the (sole)
> culprit setting promisc mode should not help, should it?
> 
> Problem exists with both 2.6.26-1-amd64 from Debian lenny and vanilla
> 2.6.27-rc8 from kernel.org (same config).
> 
> Does anyone have enough insight into how this ethernet port and the iLO
> are connected which could help blaming either the driver or the iLO (or
> both)?  I'll try to kick HP as well but since I don't have a support
> contract for this (private) system other than the hardware warranty it
> might take a while.
> 
> .config and dmesg available on request, I don't think they are helpful
> here.
> 
> Regards,
> Bernhard

It sounds like the iLO2 firmware is messing around with the rx filter.
I've heard of problems like this before with another management agent.

Can you give me the output to 'ethtool -i <device>' and the iLO2
firmware version?


