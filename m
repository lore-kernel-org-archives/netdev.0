From: ivan <khorivan@gmail.com>
Subject: [RFC] ethtool bandwidth per-queue commands
Date: Wed, 20 Jul 2016 23:00:31 +0300
Message-ID: <578FD85F.7080508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kan.liang@intel.com, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:34197 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754679AbcGTUAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 16:00:33 -0400
Received: by mail-lf0-f48.google.com with SMTP id l69so45733535lfg.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 13:00:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone.

The ethtool interface has ETHTOOL_PERQUEUE command that is used to
read/set per-queue parameters for multiqueue Ethernet devices.

I want to apply additional per-queue commands like per-queue bandwidth
and per-queue number of descriptors (like number of rings).

Currently only ETHTOOL_G/SCOALESCE sub commands are added for
per-queue interface (but I haven't seen counterpart for ethtool util).

Using ETHTOOL_G/SCOALESCE per-queue command as an example,
I'm going to add 2 additional and 2 known commands for ethtool
per-queue interface:

ETHTOOL_G/SBANDWIDTH     /* Get/Set ethtool per queue bandwidth.
Bandwidth can be set with % or absolute in Mb/s */

ETHTOOL_G/SRINGPARAM     /* is going to be used to control number of
descriptors per queue in my driver */

It's not clear how PERQUEUE command splits rx and tx queues, as
they can have different enumeration and different parameters.

Actually, there are several questions:
- how to split enumeration of rx / tx queues in per queue command,
   as it uses linear bitmap to mirror affected channels.
- where is ethtool util counterpart for per queue command?
- is it correct way to use ethtool to configure h/w shaper?

In my case, by default, multi queue h/w shaper is working in
priority mode. The setting of bandwidth for queues can be used
to switch shaper to throughput aware mode when every queue can be
bandwidth limited.

-- 
Regards,
Ivan Khoronzhuk
