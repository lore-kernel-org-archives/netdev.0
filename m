From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: still having r8169 woes with XID 18000000
Date: Fri, 04 Jun 2010 15:10:47 +0300
Message-ID: <4C08ED47.1030800@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?fran=E7ois_romieu?= <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f223.google.com ([209.85.219.223]:61154 "EHLO
	mail-ew0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683Ab0FDMKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 08:10:48 -0400
Received: by ewy23 with SMTP id 23so288249ewy.1
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 05:10:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After fixing the MAC issues earlier, I'm still seeing some weird trouble
with my RTL8169sc/8110sc / XID 18000000 boards.

The box(es) were originally running 2.6.30.x kernel and everything
worked without major problems. But after upgrading to 2.6.32.x (and even
with most of the newer fixes included too), it seems that the sometimes
(not too often) some of the interfaces just won't work after reboot
(cold or hard). It's a 3-in-1 board, and usually when this happens one
of the interfaces won't work but the other two do work.

Whenever an interface is "broken", the following conditions are true:
 - forcing it to 10mbit/s and disabling autoneg will make it work
 - when it's not working ethtool -S reports rx_errors and align_errors
increasing
 - when autoneg is on, ethtool says that "Link Detected: no"

I do see that between the above two kernel versions PHY init code was
introduced for this XID (RTL_GIGA_MAC_VER_05) in commit 2e955856ff. I
wonder if it makes sense trying to revert this. Should the NIC still
work? Do you see any other suspicious commits?

Unrelated, I notice that if I have 1GB links autonegotiated, 'ip link'
will show them as "state UNKNOWN". Forced manual links get "state UP" as
expected. This is for the operstate field.

- Timo
