From: Jeroen van Ingen <jeroen@zijndomein.nl>
Subject: ipv4: broadcast sometimes leaves wrong interface (since commit
 e066008b38ca9ace1b6de8dbbac8ed460640791d)
Date: Tue, 29 Nov 2011 17:44:47 +0100
Message-ID: <1322585087.25018.115.camel@icts-sp-039>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.utsp.utwente.nl ([130.89.2.14]:59505 "EHLO mx.utwente.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751530Ab1K2RQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 12:16:09 -0500
Received: from [130.89.36.18] (icts-sp-039.itbe.utwente.nl [130.89.36.18])
          by mx.utwente.nl (8.12.10/SuSE Linux 0.7) with ESMTP id pATGimPV029125
          for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 17:44:48 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We're having an issue on our Linux PPTP servers. After the first PPTP
client is connected, locally generated broadcast packets go out the ppp0
interface while the routing rules should select eth0.

Some details were already mentioned on the linux-kernel list, see eg
http://lkml.indiana.edu/hypermail/linux/kernel/1111.2/00290.html for
reference.

Finally we were able to narrow it down to one specific commit:
e066008b38ca9ace1b6de8dbbac8ed460640791d ("ipv4: Fix __ip_dev_find() to
use ifa_local instead of ifa_address."). With all recent kernels (tested
up to 3.2.0rc3) we observe this issue and it's solved by reverting this
single patch.

This is the first time we've had to debug a kernel issue. Any advice on
how to proceed would be very welcome. If it's not possible to have this
patch reverted in the kernel, hopefully someone can explain how to work
around this behavior.


Regards,

Jeroen van Ingen
ICT Service Centre
University of Twente, P.O.Box 217, 7500 AE Enschede, The Netherlands
