From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Wed, 22 Apr 2015 18:41:33 -0400 (EDT)
Message-ID: <20150422.184133.132510003688162502.davem@davemloft.net>
References: <553814F0.40405@cogentembedded.com>
	<20150422.181813.1931455043058560592.davem@davemloft.net>
	<553821F8.8050300@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitsuhiro.kimura.kc@renesas.com, f.fainelli@gmail.com,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com, linux-sh@vger.kernel.org,
	masaru.nagai.vx@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934632AbbDVWlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 18:41:36 -0400
In-Reply-To: <553821F8.8050300@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 23 Apr 2015 01:34:32 +0300

>    Sigh... I'm seeing no way out of that then, only copying. :-(

What exactly is the device's restriction?

Any reasonable modern chip allows one of two things.

Either it allows arbitrary alignment of the start of the TX
frame when DMA'ing.

_or_

It allows a variable number of pad bytes to be inserted by the
driver before giving it to the card, which do not go onto the
wire, in order to meet the device's DMA restrictions.

For example, if the packet is only 2 byte aligned, you set the "ignore
offset" to 2 and push two zero bytes in front of the ethernet frame
before giving it to the card.

If a chip made in this day and era cannot do one of those two things,
this is beyond disappointing and is a massive engineering failure.
Whoever designed this chip made no investigation into how their
hardware is going to be actually used.
