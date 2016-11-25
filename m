From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 25 Nov 2016 07:49:35 -0500
Message-ID: <1816ec7e-2733-f4ba-5d30-29dbabd20aad@pobox.com>
References: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
 <20161124.121140.2054576632424977475.davem@davemloft.net>
 <c3ca9e10-64de-2454-b99a-19e8302f5c12@pobox.com>
 <20161125002702.GA14085@electric-eye.fr.zoreil.com>
 <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd@pobox.com>
 <20161125095350.GA20653@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        David Miller <davem@davemloft.net>, hayeswang@realtek.com,
        netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pb-sasl2.pobox.com ([64.147.108.67]:51333 "EHLO
        sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752480AbcKYMuT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 07:50:19 -0500
In-Reply-To: <20161125095350.GA20653@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-25 04:53 AM, Greg KH wrote:
> On Thu, Nov 24, 2016 at 10:49:33PM -0500, Mark Lord wrote:
>> There is no possibility for them to be used for anything other than
>> USB receive buffers, for this driver only.  Nothing in the driver
>> or kernel ever writes to those buffers after initial allocation,
>> and only the driver and USB host controller ever have pointers to the buffers.
> 
> You really are going to have to break out that USB monitor to verify
> that this is the data coming across the wire.

Not sure why, because there really is no other way for the data to
appear where it does at the beginning of that URB buffer.

This does seem a rather unexpected burden to place upon someone
reporting a regression in a USB network driver that corrupts user data.

I have already spent about 50 hours looking at this issue,
and everything now points firmly at some kind of FIFO overflow
within the dongle itself.  There is no evidence to the contrary.

I am very happy to test any driver updates, or data collection mods
provided by the author, to help the author find/fix the issue.

One idea, might be to have the author try testing with the dongle
connected through a USB1.1 hub, forcing it to slower speeds.
This might make reproducing the issue (if indeed a FIFO overflow)
easier, as the host transfers will then be slower than the
ethernet wire speed.

I have access to the hardware here next Tuesday.
If we can scrounge up the USB analyzer, cables, and a suitable
MS-Windows (ugh) machine of some kind, then I'll see if it can
be programmed to somewhow capture the event.  Probably just set it
in continuous capture mode, and have the target system halt
when it sees bad data at offset zero.

This can take days to reproduce, so don't hold your breaths.

Something useful to do in the meanwhile, is to then think
about "what next" after the analyzer confirms the issue.
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
