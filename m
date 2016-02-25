From: Tomas Hlavacek <tmshlvck@gmail.com>
Subject: RFC: blueprint for proxy PHY module
Date: Thu, 25 Feb 2016 14:26:00 +0100
Message-ID: <1456406760.28260.6@smtp.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: Pavol =?iso-8859-2?q?Kor=E8ek?= <ikorcek@fit.vutbr.cz>,
	Martin =?iso-8859-2?q?Strba=E8ka?= <martin.strbacka@nic.cz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37382 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760194AbcBYN0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 08:26:03 -0500
Received: by mail-wm0-f52.google.com with SMTP id g62so27565900wme.0
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 05:26:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

We have a board with a MAC in SoC that has SGMII connected through a 
signal switch to either 10/100/1000 wired PHY or to a SFP cage. The 
signal switch is set to pass signal to the wired PHY by default. When 
the MOD-DEF0 pin from SFP cage is low (which acts as a 
transceiver-present signal) the wired PHY is being disconnected and the 
SGMII is passed to the SFP cage. We also have the signal connected to a 
GPIO input, so we can detect the SFP presence from software. And there 
is always-connected MDIO to the wired PHY.

Now I use two different DTBs for testing purposes, one has a 
configuration for the wired PHY and another one uses fixed-link for 
SFP. And I have to reboot in order to switch from one to another.

My idea is to create a "proxy PHY" module that would take state from 
one of two (or more) underlying PHYs and pass it to the NIC driver. The 
selection of the active PHY would come from userspace. (There will be a 
board-specific
daemon that would react to the GPIO change and set the proper PHY 
accordingly.) Question is how to connect the userspace? I think that 
corresponding file in /sys would do the job, but I am not sure whether 
it is the proper way of doing that. (?)

What do you think about it?

Thanks,
Tomas
