From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Network kernel panics with wireless-testing 3.4-rc7
Date: Mon, 21 May 2012 22:39:10 -0500
Message-ID: <4FBB0A5E.4010007@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:56206 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759467Ab2EVDjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 23:39:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am getting kernel panics on one of my boxes from the b43legacy driver due to a 
"Fatal exception in interrupt".

This particular one happened 50K seconds after bootup, but it has happened 
nearly as soon as the network connection was completed. The hand-transcribed 
traceback is as follows:

__nefif_schedule+0x13/0xa0
ieee80211_propagate_queue_wake+0x166/0x1c0
__ieee80211_wake_queue+0x13b/0x2d0
? __ieee80211_wake_queue++0xc0/0x2d0
ieee80211_wake_queue_by_reason+0x45/0x70
ieee80211_wake_queue+0xb/0x10
b43legacy_dma_handle_txstatus+0x3f9/0x4b0
? _raw_spin_unlock+0x26/0x40
b43legacy_handle_txstatus+0x64/0x90
b43legacy_handle_hwtxstatus+0x66/0x70
b43legacy_dma_rx+0x354/0x610

The offsets are for an x86_64 architecture.

These crashes never happen when I use a USB device running the rtl8187 driver, 
thus it appears to arise in b43legacy. Any suggestions on what might cause the 
problem would be helpful. Sorry I don't have the register dumps, etc.

The code dump at the point of the crash is as follows:
ec 10 4c 89 65 f8 48 89 5d f0 49 89 fc <3c> 0f ba af 80 00 00 00 00

Larry
