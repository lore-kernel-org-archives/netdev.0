From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: rp_filter backward compatibility
Date: Mon, 30 Aug 2010 17:25:22 +0200
Message-ID: <4C7BCD62.3030805@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36766 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754869Ab0H3PZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 11:25:27 -0400
Received: by wwb28 with SMTP id 28so7440092wwb.1
        for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 08:25:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm surprised by the commit 27fed4175acf81ddd91d9a4ee2fd298981f60295 (ip: fix 
logic of reverse path filter sysctl). This commit breaks backward compatibility.
I know that logic was wrong, but for years it was mandatory to set both 
all.rp_filter and <device>.rp_filter to enable it, ie setting only all.rp_filter 
had no consequences. Now, when all.rp_filter is enabled, RPF is enabled for all 
interfaces.
Help of Kconfig explains:

                                                                 "To turn
           rp_filter on use:

           echo 1 > /proc/sys/net/ipv4/conf/<device>/rp_filter
            *and*
           echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter"

At least, one of this action should be done:
  - fixing help (Documentation/networking/ip-sysctl.txt is up to date)
  - reverting the patch (this will force to set all.rp_filter to 3 if some 
interfaces use loose mode and some others strict mode)

What is your opinion?

Regards,
Nicolas
